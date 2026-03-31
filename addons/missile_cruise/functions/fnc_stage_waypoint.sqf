#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Cruise missile WAYPOINT stage.
 * Leg-following waypoint navigation with smooth inscribed-arc turns.
 * Aims at a look-ahead point on the active leg line, not the waypoint itself.
 * Transitions between legs early enough to inscribe a smooth arc through waypoints.
 * Transitions to APPROACH (if attack direction set) or POPUP when all waypoints exhausted.
 *
 * Arguments:
 * Stage args array from dispatcher (see fnc_attackProfile.sqf)
 *
 * Return Value:
 * [returnTargetPosition, terrainFollowAimDirection] <ARRAY>
 *
 * Public: No
 */

params [
    "_projectile", "_projectilePosition", "_projectilePositionAGL", "_currentAGL",
    "_velocity", "_speed", "_velocityDirection",
    "_targetPositionASL", "_horizontalDistance", "_distanceToTarget",
    "_attackProfileStateParams", "_gpsData",
    "_hasAttackDirection", "_attackDirection", "_attackDirectionVector", "_attackDirectionVectorReverse",
    "_yawRate", "_pitchRate", "_yawRadius", "_pitchRadius",
    "_yawRateEffective", "_pitchRateEffective",
    "_reactionDistance", "_popupHeight", "_popupTransitionDistance",
    "_impactAngle",
    "_seekerTargetPosition",
    "_targetData"
];

_attackProfileStateParams params ["", "", "_cruiseAltitude", "", "_launchPosition", "_lastDesiredAltitude", "_waypoints", "_currentWaypointIndex"];

private _returnTargetPosition = _seekerTargetPosition;
private _terrainFollowAimDirection = [0, 0, 0];

if (_currentWaypointIndex >= count _waypoints) then {
    if (_hasAttackDirection) then {
        TRACE_1("WAYPOINT: all waypoints exhausted, transitioning to APPROACH",_currentWaypointIndex);
        _attackProfileStateParams set [0, STAGE_APPROACH];
    } else {
        private _headingOrigin = if (_currentWaypointIndex > 0) then {
            _waypoints#(_currentWaypointIndex - 1)
        } else {
            _projectilePosition
        };
        private _deltaX = _targetPositionASL#0 - _headingOrigin#0;
        private _deltaY = _targetPositionASL#1 - _headingOrigin#1;
        private _heading = (_deltaX atan2 _deltaY + 360) mod 360;
        TRACE_2("WAYPOINT: exhausted, no attack dir -> POPUP",_currentWaypointIndex,_heading);
        _gpsData set [2, _heading];
        _attackProfileStateParams set [0, STAGE_POPUP];
    };
} else {
    private _currentWaypoint = _waypoints select _currentWaypointIndex;
    if (!(_currentWaypoint isEqualType []) || {count _currentWaypoint < 3}) then {
        ERROR_5("WAYPOINT: invalid WP type=%1 idx=%2 count=%3 val=%4 allWPs=%5",typeName _currentWaypoint,_currentWaypointIndex,count _currentWaypoint,_currentWaypoint,_waypoints);
        _attackProfileStateParams set [7, _currentWaypointIndex + 1];
    } else {
        // Previous waypoint (or launch pos for first leg)
        private _previousWaypoint = if (_currentWaypointIndex > 0) then {
            _waypoints#(_currentWaypointIndex - 1)
        } else {
            _launchPosition
        };

        // Current leg direction and length
        private _legVector = [_currentWaypoint#0 - _previousWaypoint#0, _currentWaypoint#1 - _previousWaypoint#1, 0];
        private _legLength = vectorMagnitude _legVector;
        private _legDirection = if (_legLength > 0.1) then {_legVector vectorMultiply (1 / _legLength)} else {_velocityDirection};

        // Project missile onto current leg (along-track distance from prevWP)
        private _relativePosition = [_projectilePosition#0 - _previousWaypoint#0, _projectilePosition#1 - _previousWaypoint#1, 0];
        private _alongTrack = _relativePosition vectorDotProduct _legDirection;
        private _remainingOnLeg = _legLength - _alongTrack;

        // Compute next leg info for turn calculation
        // For the last WP, the "next leg" is toward the target along the attack direction
        private _nextWaypointIndex = _currentWaypointIndex + 1;
        private _hasNextLeg = false;
        private _nextLegDirection = [0, 0, 0];
        private _nextLegLength = 0;
        private _transitionDistance = 0;

        if (_nextWaypointIndex < count _waypoints) then {
            // Normal next waypoint
            private _nextWaypoint = _waypoints#_nextWaypointIndex;
            private _nextLegVector = [_nextWaypoint#0 - _currentWaypoint#0, _nextWaypoint#1 - _currentWaypoint#1, 0];
            _nextLegLength = vectorMagnitude _nextLegVector;
            if (_nextLegLength > 0.1) then {
                _nextLegDirection = _nextLegVector vectorMultiply (1 / _nextLegLength);
                _hasNextLeg = true;
            };
        } else {
            // Last waypoint: virtual next leg toward target
            private _toTargetVector = [_targetPositionASL#0 - _currentWaypoint#0, _targetPositionASL#1 - _currentWaypoint#1, 0];
            _nextLegLength = vectorMagnitude _toTargetVector;
            if (_nextLegLength > 0.1) then {
                _nextLegDirection = if (_hasAttackDirection) then {_attackDirectionVector} else {_toTargetVector vectorMultiply (1 / _nextLegLength)};
                _hasNextLeg = true;
            };
        };

        // Inscribed arc transition: R * tan(θ/2) at full yaw rate.
        // _yawRadius is computed at RATE_USAGE (80%) for sustained-flight calculations,
        // but during a dedicated turn the guidance drives the missile at near-full rate.
        // Using the full-rate radius gives a tighter arc that matches the actual turn
        // the missile will fly, preventing premature transition.
        if (_hasNextLeg) then {
            private _cosAngle = (_legDirection vectorDotProduct _nextLegDirection) max -0.99 min 0.99;
            private _turnAngle = acos _cosAngle;
            if (_turnAngle > 1) then {
                private _fullRateYawRadius = if (_yawRate > 0.1) then {_speed / (_yawRate * (pi / 180))} else {_speed * 100};
                _transitionDistance = (_fullRateYawRadius * tan (_turnAngle / 2)) min (_legLength * 0.4) min (_nextLegLength * 0.4);
            };
        };

        // Determine which leg to follow and whether to advance
        private _followDirection = _legDirection;
        private _followStart = _previousWaypoint;
        private _followLength = _legLength;
        private _advance = false;

        if (_hasNextLeg && {_remainingOnLeg <= _transitionDistance}) then {
            // Within transition zone: switch to following next leg
            _followDirection = _nextLegDirection;
            _followStart = _currentWaypoint;
            _followLength = _nextLegLength;
            _advance = true;
        } else {
            if (_remainingOnLeg <= 0) then {
                // Past the WP: advance and follow next leg if available
                _advance = true;
                if (_hasNextLeg) then {
                    _followDirection = _nextLegDirection;
                    _followStart = _currentWaypoint;
                    _followLength = _nextLegLength;
                };
            };
        };

        if (_advance) then {
            TRACE_3("WAYPOINT: advancing",_currentWaypointIndex,_remainingOnLeg,_transitionDistance);
            _attackProfileStateParams set [7, _currentWaypointIndex + 1];
        };

        // Aim at look-ahead point on the active leg.
        // Look-ahead = reaction distance + yaw arc for the current error.
        // Reaction distance provides a floor: even at 0° error the missile
        // needs reaction time before turning, keeping the aim close enough
        // for meaningful correction at small offsets.
        private _relativeToFollow = [_projectilePosition#0 - _followStart#0, _projectilePosition#1 - _followStart#1, 0];
        private _followAlongTrack = _relativeToFollow vectorDotProduct _followDirection;
        private _crossTrackError = abs ((_relativeToFollow#0 * _followDirection#1) - (_relativeToFollow#1 * _followDirection#0));

        private _horizontalVelocity = vectorNormalized [_velocityDirection#0, _velocityDirection#1, 0];
        private _headingAlignment = _horizontalVelocity vectorDotProduct _followDirection;
        private _headingAngle = acos (_headingAlignment max -1 min 1);

        // Heading arc: yaw radius * sin(headingAngle)
        // Cross-track arc: ≈ crossTrackError for E << R (exact: R * sin(atan(E/R)))
        private _headingArcDistance = _yawRadius * sin _headingAngle;
        private _correctionArcDistance = _headingArcDistance max (_crossTrackError min _yawRadius);
        private _lookAhead = (_reactionDistance + _correctionArcDistance) min _followLength;

        // Leg line aim: point on the follow leg for cross-track correction
        private _aimTrack = ((_followAlongTrack max 0) + _lookAhead) min _followLength;
        private _legAimPoint = [
            _followStart#0 + _followDirection#0 * _aimTrack,
            _followStart#1 + _followDirection#1 * _aimTrack,
            0
        ];

        // Arc aim: predict turn by rotating velocity toward follow direction at 80% yaw rate.
        // Eliminates pursuit-curve overshoot by tracing the arc the missile will actually fly.
        private _lookAheadTime = _lookAhead / (_speed max 1);
        private _turnAngleForLookAhead = (_yawRateEffective * _lookAheadTime) min _headingAngle;
        private _arcAimPoint = +_legAimPoint;

        if (_turnAngleForLookAhead > 0.5) then {
            private _cross = (_horizontalVelocity#0 * _followDirection#1) - (_horizontalVelocity#1 * _followDirection#0);
            private _turnSign = if (_cross >= 0) then {1} else {-1};
            private _rotateAngle = _turnSign * _turnAngleForLookAhead;
            private _cosRotation = cos _rotateAngle;
            private _sinRotation = sin _rotateAngle;
            private _predictedDirection = [
                (_horizontalVelocity#0) * _cosRotation - (_horizontalVelocity#1) * _sinRotation,
                (_horizontalVelocity#0) * _sinRotation + (_horizontalVelocity#1) * _cosRotation,
                0
            ];
            _arcAimPoint = [
                _projectilePosition#0 + _predictedDirection#0 * _lookAhead,
                _projectilePosition#1 + _predictedDirection#1 * _lookAhead,
                0
            ];
        };

        // Blend: heading arc / yaw radius. Proportional to how much of the
        // yaw capability is needed for the heading correction.
        // Heading off → arc aim (completes turn), aligned → leg aim (cross-track correction).
        private _arcBlend = (_headingArcDistance / _yawRadius) min 1;
        private _aimOnLeg = [
            _legAimPoint#0 * (1 - _arcBlend) + _arcAimPoint#0 * _arcBlend,
            _legAimPoint#1 * (1 - _arcBlend) + _arcAimPoint#1 * _arcBlend,
            0
        ];

        // Sample terrain along curved path from velocity toward aim-on-leg point
        _terrainFollowAimDirection = vectorNormalized [_aimOnLeg#0 - _projectilePosition#0, _aimOnLeg#1 - _projectilePosition#1, 0];
        private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(terrainFollowSmooth);
        _attackProfileStateParams set [5, _smoothedAltitude];

        // terrainFollowAimPoint handles altitude authority (clamps aim distance for pitch control)
        _returnTargetPosition = [_aimOnLeg, _smoothedAltitude, _projectilePosition, _velocityDirection, _pitchRate, _speed] call FUNC(terrainFollowAimPoint);

        // Clamp descent angle to prevent overly steep dives during transition to waypoint navigation from high alt launch
        private _wpHorizontalDist = sqrt ((_returnTargetPosition#0 - _projectilePosition#0) * (_returnTargetPosition#0 - _projectilePosition#0) + (_returnTargetPosition#1 - _projectilePosition#1) * (_returnTargetPosition#1 - _projectilePosition#1));
        private _wpMinAltitude = _projectilePosition#2 - (_wpHorizontalDist * tan LAUNCH_MAX_DESCENT_ANGLE);
        _returnTargetPosition set [2, (_returnTargetPosition#2) max _wpMinAltitude];
    };
};

[_returnTargetPosition, _terrainFollowAimDirection]
