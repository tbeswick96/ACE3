#include "..\script_component.hpp"
#include "..\cruise_missile_defines.hpp"
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

#define LAUNCH_MIN_DIST 500
#define LAUNCH_MAX_DESCENT_ANGLE 50
#define DEFAULT_IMPACT_ANGLE 45

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

                // Clamp descent angle to prevent overly steep dives during transition to waypoint navigation from high alt launch
                private _wpHorizontalDist = sqrt ((_returnTargetPosition#0 - _projectilePosition#0) * (_returnTargetPosition#0 - _projectilePosition#0) + (_returnTargetPosition#1 - _projectilePosition#1) * (_returnTargetPosition#1 - _projectilePosition#1));
                private _wpMinAltitude = _projectilePosition#2 - (_wpHorizontalDist * tan LAUNCH_MAX_DESCENT_ANGLE);
                _returnTargetPosition set [2, (_returnTargetPosition#2) max _wpMinAltitude];
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
        if ((_horizontalDistance <= _terminalDistance && {_currentAltAboveTarget >= _popupHeight * 0.5}) || {_horizontalDistance < 200 && {_currentAltAboveTarget > 0}}) then {
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

    [_projectile, _projectilePosition, _velocityDirection, _speed,
        _currentAGL, _horizontalDistance,
        _attackProfileStateParams, _targetPositionASL,
        _hasAttackDirection, _attackDirectionVector,
        _returnTargetPosition, _terrainFollowAimDirection,
        _yawRate, _pitchRate
    ] call FUNC(cruise_missile_debugDraw);
};

_returnTargetPosition
