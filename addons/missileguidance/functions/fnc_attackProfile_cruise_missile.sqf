#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Attack profile: Cruise Missile
 * 6-stage state machine: LAUNCH -> WAYPOINT/CRUISE -> APPROACH -> POPUP -> TERMINAL
 * Terrain-following cruise flight with configurable altitude, waypoint navigation,
 * approach from attack direction, pop-up maneuver, and terminal dive.
 *
 * Arguments:
 * 0: Seeker Target PosASL <ARRAY>
 * 1: Guidance Arg Array <ARRAY>
 * 2: Attack Profile State <ARRAY>
 * 3: Timestep <NUMBER>
 *
 * Return Value:
 * Missile Aim PosASL <ARRAY>
 *
 * Example:
 * [[1,2,3], [], [], 0.1] call ace_missileguidance_fnc_attackProfile_cruise_missile;
 *
 * Public: No
 */

#define STAGE_LAUNCH    1
#define STAGE_CRUISE    2
#define STAGE_WAYPOINT  3
#define STAGE_APPROACH  4
#define STAGE_POPUP     5
#define STAGE_TERMINAL  6

#define LAUNCH_MIN_DIST 500
#define DEFAULT_IMPACT_ANGLE 45
#define RATE_USAGE 0.8
#define RESPONSE_TIME 1

params ["_seekerTargetPosition", "_args", "_attackProfileStateParams", "_timestep"];
_args params ["_firedEH", "", "_flightParams", "", "", "_targetData"];
_firedEH params ["_shooter","","","","","","_projectile"];
_targetData params ["_directionToTarget", "", "_distanceToTarget"];
_flightParams params ["_pitchRate", "_yawRate"];

_attackProfileStateParams params [
    "_stage",
    "_gpsData",
    "_cruiseAltitude",
    "_approachWaypoint",
    "_launchPosition",
    "_lastDesiredAltitude",
    "_waypoints",
    "_currentWaypointIndex"
];

_gpsData params ["_targetPosition", "_impactAngle", "_attackDirection"];

if (_seekerTargetPosition isEqualTo [0,0,0]) exitWith {_seekerTargetPosition};

private _projectilePosition = getPosASLVisual _projectile;
private _projectilePositionAGL = ASLToAGL _projectilePosition;
private _currentAGL = _projectilePositionAGL#2;
private _returnTargetPosition = _seekerTargetPosition;
private _terrainFollowAimDirection = [0, 0, 0]; // Set per-stage: aim direction for TF curved path sampling

// Safe velocity extraction — vectorDir always returns a valid unit vector
private _velocity = velocity _projectile;
private _speed = vectorMagnitude _velocity;
private _velocityDirection = if (_speed > 0.1) then {
    _velocity vectorMultiply (1 / _speed)
} else {
    vectorDir _projectile
};

// Use target from GPS data
private _targetPositionASL = +_targetPosition;
if (_targetPositionASL#2 < 1) then {
    _targetPositionASL set [2, (getTerrainHeightASL _targetPositionASL) max 0];
};

private _distanceToTarget = _projectilePosition vectorDistance _targetPositionASL;
private _horizontalDistance = [_projectilePosition#0, _projectilePosition#1, 0] vectorDistance [_targetPositionASL#0, _targetPositionASL#1, 0];

// Default impact angle
if (_impactAngle <= 0) then {
    _impactAngle = DEFAULT_IMPACT_ANGLE;
};

// Popup height scales with impact angle (design parameter)
private _popupHeight = linearConversion [20, 80, _impactAngle, 150, 600, true];

// Default attack direction to current heading if not set
private _hasAttackDirection = _attackDirection >= 0;
if (!_hasAttackDirection) then {
    _attackDirection = direction _projectile;
};

// Attack direction as unit vector (used by multiple stages)
private _attackDirectionVector = [1, _attackDirection, 0] call CBA_fnc_polar2vect;
private _attackDirectionVectorReverse = _attackDirectionVector vectorMultiply -1;

// Physics-based turn radii at 80% max rate (circular arc model)
// R = speed / angular_velocity_in_rad_per_sec
private _yawRateEffective = _yawRate * RATE_USAGE;
private _pitchRateEffective = _pitchRate * RATE_USAGE;
private _yawRadius = if (_yawRateEffective > 0.1) then {
    _speed / (_yawRateEffective * (pi / 180))
} else {
    _speed * 100
};
private _pitchRadius = if (_pitchRateEffective > 0.1) then {
    _speed / (_pitchRateEffective * (pi / 180))
} else {
    _speed * 100
};

// Reaction distance: straight flight during control surface response lag
private _reactionDistance = _speed * RESPONSE_TIME;

// Popup transition distance: two-arc model (pull-up + push-over to dive)
// Height = R_pitch * (1 + cos(impactAngle) - 2*cos(theta))
// Horizontal = R_pitch * (2*sin(theta) + sin(impactAngle))
private _pullUpCosTheta = ((1 + cos _impactAngle) / 2) - (_popupHeight / (2 * _pitchRadius));
_pullUpCosTheta = _pullUpCosTheta max -1 min 1;
private _pullUpAngle = acos _pullUpCosTheta;
private _popupTransitionDistance = _pitchRadius * ((2 * sin _pullUpAngle) + sin _impactAngle);

switch (_stage) do {
    case STAGE_LAUNCH: {
        // Climb to cruise altitude, turn toward first navigation target
        private _targetAltitudeASL = ((getTerrainHeightASL _projectilePosition) max 0) + _cruiseAltitude;

        // Aim at first waypoint if set, else target
        private _aimPosition = if (count _waypoints > 0) then {
            +(_waypoints#0)
        } else {
            +_targetPositionASL
        };
        _aimPosition set [2, _targetAltitudeASL max (_aimPosition#2)];

        _returnTargetPosition = _aimPosition;

        // Seed lastDesiredAlt so TF smoother has a valid starting value at transition
        _attackProfileStateParams set [5, _targetAltitudeASL];

        // Transition: at cruise alt AND far enough from launch
        private _launchDistance = _projectilePosition vectorDistance _launchPosition;
        if (_currentAGL >= (_cruiseAltitude * 0.9) && {_launchDistance > LAUNCH_MIN_DIST}) then {
            if (count _waypoints > 0) then {
                TRACE_2("LAUNCH->WAYPOINT",count _waypoints,_waypoints);
                _attackProfileStateParams set [0, STAGE_WAYPOINT];
                _attackProfileStateParams set [7, 0];
            } else {
                _attackProfileStateParams set [0, STAGE_CRUISE];
            };
        };
    };

    case STAGE_CRUISE: {
        // Only used when no waypoints and no attack direction — beeline to target
        // Sample terrain along curved path from velocity toward target
        _terrainFollowAimDirection = vectorNormalized [_targetPositionASL#0 - _projectilePosition#0, _targetPositionASL#1 - _projectilePosition#1, 0];
        private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(cruise_missile_tfSmooth);
        _attackProfileStateParams set [5, _smoothedAltitude];

        _returnTargetPosition = [_targetPositionASL, _smoothedAltitude, _projectilePosition, _velocityDirection, _pitchRate, _speed] call FUNC(cruise_missile_tfAimPoint);

        if (_horizontalDistance < _popupTransitionDistance) then {
            // Lock heading from missile to target (no configured attack dir in CRUISE)
            private _deltaX = _targetPositionASL#0 - _projectilePosition#0;
            private _deltaY = _targetPositionASL#1 - _projectilePosition#1;
            _gpsData set [2, (_deltaX atan2 _deltaY + 360) % 360];
            _attackProfileStateParams set [0, STAGE_POPUP];
        };
    };

    case STAGE_WAYPOINT: {
        // Leg-following waypoint navigation with smooth inscribed-arc turns.
        // Aims at a look-ahead point on the active leg line, not the waypoint itself.
        // Transitions between legs early enough to inscribe a smooth arc through waypoints.
        // tfSmooth is called AFTER aim direction is known, so terrain is sampled along the flight path.

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
                private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(cruise_missile_tfSmooth);
                _attackProfileStateParams set [5, _smoothedAltitude];

                // tfAimPoint handles altitude authority (clamps aim distance for pitch control)
                _returnTargetPosition = [_aimOnLeg, _smoothedAltitude, _projectilePosition, _velocityDirection, _pitchRate, _speed] call FUNC(cruise_missile_tfAimPoint);
            };
        };
    };

    case STAGE_APPROACH: {
        // Sample terrain along curved path from velocity toward attack direction
        _terrainFollowAimDirection = _attackDirectionVector;
        private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(cruise_missile_tfSmooth);
        _attackProfileStateParams set [5, _smoothedAltitude];

        // Project missile onto the attack line through target
        // Line: P(projection) = target + projection * attackDirection, projection<0 = approaching, projection=0 = at target
        private _lineProjection = (_projectilePosition vectorDiff _targetPositionASL) vectorDotProduct _attackDirectionVector;

        // Horizontal lead: reaction distance + yaw arc for heading/cross-track error
        private _approachHorizontalVelocity = vectorNormalized [_velocityDirection#0, _velocityDirection#1, 0];
        private _approachHeadingAngle = acos ((_approachHorizontalVelocity vectorDotProduct _attackDirectionVector) max -1 min 1);
        private _relToTarget = [_projectilePosition#0 - _targetPositionASL#0, _projectilePosition#1 - _targetPositionASL#1, 0];
        private _attackCrossTrack = abs ((_relToTarget#0 * _attackDirectionVector#1) - (_relToTarget#1 * _attackDirectionVector#0));
        private _approachHeadingArc = _yawRadius * sin _approachHeadingAngle;
        private _approachCorrectionArc = _approachHeadingArc max (_attackCrossTrack min _yawRadius);
        private _leadDistance = (_reactionDistance + _approachCorrectionArc) min _horizontalDistance;
        private _aimParam = (_lineProjection + _leadDistance) min 0;
        private _aimPosition = _targetPositionASL vectorAdd (_attackDirectionVector vectorMultiply _aimParam);
        _aimPosition set [2, _smoothedAltitude];

        // Cap aim distance for pitch authority: reaction distance + pitch arc for altitude error
        private _approachAltitudeError = abs (_smoothedAltitude - _projectilePosition#2);
        private _approachClimbRatio = (_approachAltitudeError / _pitchRadius) min 1;
        private _approachArcAngle = acos (1 - _approachClimbRatio);
        private _approachPitchLeadDistance = _reactionDistance + _pitchRadius * sin _approachArcAngle;

        private _deltaX = _aimPosition#0 - _projectilePosition#0;
        private _deltaY = _aimPosition#1 - _projectilePosition#1;
        private _aimHorizontalDistance = sqrt (_deltaX * _deltaX + _deltaY * _deltaY);
        if (_aimHorizontalDistance > _approachPitchLeadDistance) then {
            private _scale = _approachPitchLeadDistance / _aimHorizontalDistance;
            _aimPosition = [
                _projectilePosition#0 + _deltaX * _scale,
                _projectilePosition#1 + _deltaY * _scale,
                _smoothedAltitude
            ];
        };

        _returnTargetPosition = _aimPosition;

        // Pop up at the computed transition distance. The popup stage handles residual
        // heading and cross-track correction during climb, so delaying for perfect
        // alignment risks running out of room for the pull-up at high impact angles.
        if (_horizontalDistance < _popupTransitionDistance) then {
            _attackProfileStateParams set [0, STAGE_POPUP];
        };
    };

    case STAGE_POPUP: {
        // Climb to popup altitude for terminal dive
        private _popupAltitudeASL = ((getTerrainHeightASL _targetPositionASL) max 0) + _popupHeight;

        // Aim along attack line at popup altitude, converging to above-target as we close in.
        // Lead = reaction distance + yaw arc for heading error: allows lateral course correction during climb.
        private _lineProjection = (_projectilePosition vectorDiff _targetPositionASL) vectorDotProduct _attackDirectionVector;
        private _popupHorizontalVelocity = vectorNormalized [_velocityDirection#0, _velocityDirection#1, 0];
        private _popupHeadingAngle = acos ((_popupHorizontalVelocity vectorDotProduct _attackDirectionVector) max -1 min 1);
        private _popupLeadDistance = (_reactionDistance + _yawRadius * sin _popupHeadingAngle) min _horizontalDistance;
        private _aimParam = (_lineProjection + _popupLeadDistance) min 0;
        private _popupAimPosition = _targetPositionASL vectorAdd (_attackDirectionVector vectorMultiply _aimParam);
        _popupAimPosition set [2, _popupAltitudeASL];

        _returnTargetPosition = _popupAimPosition;

        // Physics-based terminal transition:
        // Pitch-over arc from current pitch to -impactAngle, then straight dive to target
        private _currentPitch = asin ((_velocityDirection#2) max -1 min 1);
        private _currentAltAboveTarget = _projectilePosition#2 - ((getTerrainHeightASL _targetPositionASL) max 0);

        // Horizontal distance for pitch-over arc (from current pitch to -impactAngle)
        private _pitchOverHorizontalDistance = _pitchRadius * ((sin _currentPitch max 0) + sin _impactAngle);

        // Height at end of pitch-over (descent during the arc)
        private _altAfterPitchOver = _currentAltAboveTarget + _pitchRadius * (cos _impactAngle - (cos _currentPitch max 0));

        // Straight dive horizontal distance from end of pitch-over to target
        private _diveHorizontalDistance = if (_impactAngle > 1 && {_altAfterPitchOver > 0}) then {
            _altAfterPitchOver / tan _impactAngle
        } else {
            0
        };

        private _terminalDistance = _pitchOverHorizontalDistance + _diveHorizontalDistance;
        if ((_horizontalDistance <= _terminalDistance && {_currentAltAboveTarget >= _popupHeight * 0.5}) || {_horizontalDistance < 200}) then {
            if (_gpsData#2 < 0) then {
                _gpsData set [2, direction _projectile];
            };
            _attackProfileStateParams set [0, STAGE_TERMINAL];
        };
    };

    case STAGE_TERMINAL: {
        // Terminal dive along impact line (JDAM-style line navigation).
        // Aim is always ON the impact line, at (distance - lead) from target.
        // This pulls the missile onto the line and maintains correct attack angle.
        private _finalAttackDirection = _gpsData#2;
        if (_finalAttackDirection < 0) then {
            _finalAttackDirection = direction _projectile;
            _gpsData set [2, _finalAttackDirection];
        };

        // lineDirection: unit vector from target UP along reverse attack direction at impact angle
        private _lineDirection = [1, 180 + _finalAttackDirection, _impactAngle] call CBA_fnc_polar2vect;

        // JDAM-style line tracking: aim at a point on the impact line, with a lead
        // distance that scales with range. The lead shrinks as the missile closes in,
        // so the aim tracks smoothly down the line all the way to the target.
        private _leadDistance = linearConversion [0, 1000, _distanceToTarget, 5, 500, true];
        private _aimPosition = _targetPositionASL vectorAdd (_lineDirection vectorMultiply ((_distanceToTarget - _leadDistance) max 0));

        // Don't aim above the missile — prevents climbing back up if already below the line
        if (_aimPosition#2 > _projectilePosition#2) then {
            _aimPosition set [2, _projectilePosition#2];
        };

        _returnTargetPosition = _aimPosition;
        _targetData set [2, _projectilePosition vectorDistance _aimPosition];
    };
};

// Debug drawing
if (GVAR(debug_drawGuidanceInfo)) then {
    private _stageNames = ["", "LAUNCH", "CRUISE", "WAYPOINT", "APPROACH", "POPUP", "TERMINAL"];
    private _stageName = _stageNames param [_stage, "UNKNOWN"];
    private _projectilePitch = ((vectorDir _projectile) call CBA_fnc_vect2polar) select 2;

    //IGNORE_PRIVATE_WARNING ["_attackProfileName"];
    _attackProfileName = format ["CRUISE [%1 | ALT:%2m | TGT:%3m | Pitch:%4]",
        _stageName,
        round _currentAGL,
        round _horizontalDistance,
        round _projectilePitch
    ];

    // Target position - red icon
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,0,0,1], ASLToAGL _targetPositionASL, 0.75, 0.75, 0, "TARGET", 1, 0.025, "TahomaB"];

    // Attack direction line - white
    if (_hasAttackDirection) then {
        private _targetAGL = ASLToAGL _targetPositionASL;
        drawLine3D [_targetAGL, _targetAGL vectorAdd (_attackDirectionVector vectorMultiply 2000), [1,1,1,1]];
    };

    // Waypoints - yellow icons with connecting lines (includes approach WP as last)
    if (count _waypoints > 0) then {
        private _previousPosition = [];
        private _lastWaypointIndex = count _waypoints - 1;
        {
            if (count _x < 3) then {continue};
            private _waypointAGL = ASLToAGL _x;
            private _isCurrent = _forEachIndex == _currentWaypointIndex;
            private _isApproach = _forEachIndex == _lastWaypointIndex && {_hasAttackDirection};
            private _color = if (_isCurrent) then {[1,1,0,1]} else {[1,0.7,0,0.6]};
            private _label = if (_isApproach) then {
                ["APP", "APP >"] select _isCurrent
            } else {
                format [["WP %1", "WP %1 >"] select _isCurrent, _forEachIndex + 1]
            };
            if (_isApproach) then {_color = [0,1,0,1]};
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", _color, _waypointAGL, 0.5, 0.5, 0, _label, 1, 0.02, "TahomaB"];
            if (_previousPosition isNotEqualTo []) then {
                drawLine3D [ASLToAGL _previousPosition, _waypointAGL, [1,0.7,0,0.4]];
            };
            _previousPosition = _x;
        } forEach _waypoints;
    };

    // Return aim position - cyan icon
    if (count _returnTargetPosition >= 3) then {
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,1,1], ASLToAGL _returnTargetPosition, 0.5, 0.5, 0, "AIM", 1, 0.025, "TahomaB"];
    } else {
        ERROR_2("drawAIM: _returnTargetPosition invalid count=%1 val=%2",count _returnTargetPosition,_returnTargetPosition);
    };

    // --- Missile height readouts (5m behind missile to reduce label clutter) ---
    // Each marker drawn at the height it represents
    private _labelASL = _projectilePosition vectorAdd (_velocityDirection vectorMultiply -5);
    private _terrainASLHere = getTerrainHeightASL _projectilePosition;
    private _missileASL = _projectilePosition#2;
    private _missileATL = _missileASL - _terrainASLHere;
    private _missileAGL = (ASLToAGL _projectilePosition)#2;

    // ASL marker (white) — drawn at missile ASL height
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,1,1],
        ASLToAGL _labelASL, 0.25, 0.25, 0,
        format ["ASL: %1m", round _missileASL], 1, 0.022, "TahomaB"];

    // ATL marker (yellow) — drawn at missile ATL height above terrain
    // ATL position in ASL = terrainASL + ATL = missileASL, so same physical point
    // Over water terrain is seabed, so ATL differs from AGL
    private _atlDrawASL = _terrainASLHere + _missileATL;
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,0,1],
        ASLToAGL [_labelASL#0 + 3, _labelASL#1, _atlDrawASL], 0.25, 0.25, 0,
        format ["ATL: %1m (ter:%2)", round _missileATL, round _terrainASLHere], 1, 0.022, "TahomaB"];

    // AGL marker (green) — drawn at missile AGL height above ground
    // AGL = ATL over land, = ASLW over water (above water surface)
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,0,1],
        ASLToAGL [_labelASL#0 - 3, _labelASL#1, _labelASL#2], 0.25, 0.25, 0,
        format ["AGL: %1m", round _missileAGL], 1, 0.022, "TahomaB"];

    // Terrain clearance (green=safe, red=danger)
    private _terrainBelowClamped = _terrainASLHere max 0;
    private _clearance = _missileASL - _terrainBelowClamped;
    private _clearanceColor = if (_clearance < _cruiseAltitude * 0.5) then {[1,0,0,1]} else {[0,1,0,1]};
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", _clearanceColor,
        ASLToAGL [_labelASL#0, _labelASL#1, _terrainBelowClamped], 0.25, 0.25, 0,
        format ["CLR: %1m", round _clearance], 1, 0.022, "TahomaB"];

    // Desired altitude marker (magenta) — drawn at the desired cruise height
    if (_stage in [STAGE_CRUISE, STAGE_WAYPOINT, STAGE_APPROACH] && {_lastDesiredAltitude > 0}) then {
        private _desiredATL = _lastDesiredAltitude - _terrainASLHere;
        private _desiredAGL = (ASLToAGL [_projectilePosition#0, _projectilePosition#1, _lastDesiredAltitude])#2;
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0, 1, 1],
            ASLToAGL [_projectilePosition#0, _projectilePosition#1, _lastDesiredAltitude], 0.5, 0.5, 0,
            format ["DES ASL:%1 ATL:%2 AGL:%3", round _lastDesiredAltitude, round _desiredATL, round _desiredAGL], 1, 0.022, "TahomaB"];
    };

    // Terminal dive line
    if (_stage == STAGE_TERMINAL) then {
        private _finalAttackDirection = _gpsData#2;
        private _lineDirection = [1, 180 + _finalAttackDirection, _impactAngle] call CBA_fnc_polar2vect;
        private _targetAGL = ASLToAGL _targetPositionASL;
        drawLine3D [_targetAGL, _targetAGL vectorAdd (_lineDirection vectorMultiply 3000), [1,0.5,0,1]];
    };

    // --- Terrain following profile with peak readouts (curved path) ---
    if (_stage in [STAGE_CRUISE, STAGE_WAYPOINT, STAGE_APPROACH]) then {
        private _profileSpeed = _speed max 30;

        // Replicate the curved path from terrainSample for debug visualization
        private _profileCurrentDirection = [_velocityDirection#0, _velocityDirection#1, 0];
        _profileCurrentDirection = if (vectorMagnitude _profileCurrentDirection > 0.01) then {vectorNormalized _profileCurrentDirection} else {[0,1,0]};
        private _profileAimDirection = [_terrainFollowAimDirection#0, _terrainFollowAimDirection#1, 0];
        _profileAimDirection = if (vectorMagnitude _profileAimDirection > 0.01) then {vectorNormalized _profileAimDirection} else {_profileCurrentDirection};

        private _profileCosTotalAngle = (_profileCurrentDirection vectorDotProduct _profileAimDirection) max -1 min 1;
        private _profileTotalAngle = acos _profileCosTotalAngle;
        private _profileCrossProduct = (_profileCurrentDirection#0 * _profileAimDirection#1) - (_profileCurrentDirection#1 * _profileAimDirection#0);
        private _profileTurnSign = if (_profileCrossProduct >= 0) then {1} else {-1};

        // Physics-based lookahead matching terrainSample: climb arc distance + margin
        private _profilePitchRadius = if (_pitchRateEffective > 0.1) then {
            _profileSpeed / (_pitchRateEffective * (pi / 180))
        } else {
            _profileSpeed * 100
        };
        private _profileClimbRatio = (_cruiseAltitude / _profilePitchRadius) min 1;
        private _profileClimbAngle = acos (1 - _profileClimbRatio);
        private _maxLookahead = ((_profilePitchRadius * sin _profileClimbAngle) * 1.5) max 200;
        private _numSamples = ceil (_maxLookahead / 100);
        private _profileStepTime = 100 / _profileSpeed;

        private _previousPoint = [];
        private _peakAltitude = 0;
        private _peakPosition = [];
        private _peakDistance = 0;

        private _profilePosition = +_projectilePosition;
        private _profileDirection = +_profileCurrentDirection;
        private _profileAngleTurned = 0;

        for "_i" from 0 to _numSamples do {
            if (_i > 0) then {
                // Rotate toward aim direction
                private _stepAngle = ((_yawRate * _profileStepTime) min (_profileTotalAngle - _profileAngleTurned)) max 0;
                if (_stepAngle > 0.01) then {
                    private _rotationAngle = _profileTurnSign * _stepAngle;
                    private _cosRotation = cos _rotationAngle;
                    private _sinRotation = sin _rotationAngle;
                    _profileDirection = [
                        (_profileDirection#0) * _cosRotation - (_profileDirection#1) * _sinRotation,
                        (_profileDirection#0) * _sinRotation + (_profileDirection#1) * _cosRotation,
                        0
                    ];
                    _profileAngleTurned = _profileAngleTurned + _stepAngle;
                };
                _profilePosition = _profilePosition vectorAdd (_profileDirection vectorMultiply 100);
            };

            private _sampleDistance = _i * 100;
            private _terrainHeight = (getTerrainHeightASL _profilePosition) max 0;
            private _requiredAltitude = _terrainHeight + _cruiseAltitude;
            private _pointAGL = ASLToAGL [_profilePosition#0, _profilePosition#1, _requiredAltitude];

            // Track peak (highest required altitude in lookahead)
            if (_requiredAltitude > _peakAltitude) then {
                _peakAltitude = _requiredAltitude;
                _peakPosition = +_profilePosition;
                _peakDistance = _sampleDistance;
            };

            // Connected terrain profile line
            if (_previousPoint isNotEqualTo []) then {
                drawLine3D [_previousPoint, _pointAGL, [1, 1, 0, 0.5]];
            };
            _previousPoint = _pointAGL;

            // Label every 4th point for clarity
            if (_i > 0 && {_i % 4 == 0}) then {
                drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,0,0.7], _pointAGL, 0.3, 0.3, 0, format ["%1m", round _sampleDistance], 1, 0.02, "TahomaB"];
            };
        };

        // --- TF peak (lookahead) readouts — each at its actual height ---
        if (_peakPosition isNotEqualTo []) then {
            private _peakTerrainASL = getTerrainHeightASL _peakPosition;
            private _peakATL = _peakAltitude - _peakTerrainASL;
            private _peakAGL = (ASLToAGL [_peakPosition#0, _peakPosition#1, _peakAltitude])#2;

            // TF PEAK header (cyan) — at cruise target ASL height
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,1,1],
                ASLToAGL [_peakPosition#0, _peakPosition#1, _peakAltitude], 0.4, 0.4, 0,
                format ["TF PEAK @%1m", round _peakDistance], 1, 0.022, "TahomaB"];

            // TGT ASL (white) — at cruise target ASL height, offset X
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,1,0.9],
                ASLToAGL [_peakPosition#0 + 3, _peakPosition#1, _peakAltitude], 0.25, 0.25, 0,
                format ["TGT ASL: %1m (ter:%2)", round _peakAltitude, round _peakTerrainASL], 1, 0.022, "TahomaB"];

            // TGT ATL (yellow) — at ATL height above terrain
            private _atlPeakASL = _peakTerrainASL + _peakATL;
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,0,0.9],
                ASLToAGL [_peakPosition#0 - 3, _peakPosition#1, _atlPeakASL], 0.25, 0.25, 0,
                format ["TGT ATL: %1m", round _peakATL], 1, 0.022, "TahomaB"];

            // TGT AGL (green) — at AGL height above ground
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,0,0.9],
                [_peakPosition#0, _peakPosition#1, _peakAGL], 0.25, 0.25, 0,
                format ["TGT AGL: %1m", round _peakAGL], 1, 0.022, "TahomaB"];
        };
    };
};

_returnTargetPosition
