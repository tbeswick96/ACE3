#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Attack profile: Cruise Missile
 * Dispatcher for 6-stage state machine: LAUNCH -> WAYPOINT/CRUISE -> APPROACH -> POPUP -> TERMINAL
 * Computes shared physics state then delegates to stage-specific functions.
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
 * [[1,2,3], [], [], 0.1] call ace_missile_cruise_fnc_attackProfile;
 *
 * Public: No
 */

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

// Safe velocity extraction
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

// Popup height scales with impact angle
private _popupHeight = linearConversion [20, 80, _impactAngle, 150, 600, true];

// Default attack direction to current heading if not set
private _hasAttackDirection = _attackDirection >= 0;
if (!_hasAttackDirection) then {
    _attackDirection = direction _projectile;
};

// Attack direction vectors
private _attackDirectionVector = [1, _attackDirection, 0] call CBA_fnc_polar2vect;
private _attackDirectionVectorReverse = _attackDirectionVector vectorMultiply -1;

// Physics-based turn radii at 90% max rate
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

// Reaction distance
private _reactionDistance = _speed * RESPONSE_TIME;

// Popup transition distance
private _pullUpCosTheta = ((1 + cos _impactAngle) / 2) - (_popupHeight / (2 * _pitchRadius));
_pullUpCosTheta = _pullUpCosTheta max -1 min 1;
private _pullUpAngle = acos _pullUpCosTheta;
private _popupTransitionDistance = _pitchRadius * ((2 * sin _pullUpAngle) + sin _impactAngle);

// Package shared state for stage functions
private _stageArgs = [
    _projectile, _projectilePosition, _projectilePositionAGL, _currentAGL,
    _velocity, _speed, _velocityDirection,
    _targetPositionASL, _horizontalDistance, _distanceToTarget,
    _attackProfileStateParams, _gpsData,
    _hasAttackDirection, _attackDirection, _attackDirectionVector, _attackDirectionVectorReverse,
    _yawRate, _pitchRate, _yawRadius, _pitchRadius,
    _yawRateEffective, _pitchRateEffective,
    _reactionDistance, _popupHeight, _popupTransitionDistance,
    _impactAngle,
    _seekerTargetPosition,
    _targetData
];

// Dispatch to stage function — each returns [returnTargetPosition, terrainFollowAimDirection]
private _stageResult = switch (_stage) do {
    case STAGE_LAUNCH:   { _stageArgs call FUNC(stage_launch) };
    case STAGE_CRUISE:   { _stageArgs call FUNC(stage_cruise) };
    case STAGE_WAYPOINT: { _stageArgs call FUNC(stage_waypoint) };
    case STAGE_APPROACH: { _stageArgs call FUNC(stage_approach) };
    case STAGE_POPUP:    { _stageArgs call FUNC(stage_popup) };
    case STAGE_TERMINAL: { _stageArgs call FUNC(stage_terminal) };
    default              { [_seekerTargetPosition, [0, 0, 0]] };
};

_stageResult params ["_returnTargetPosition", "_terrainFollowAimDirection"];

// Debug drawing
if (EGVAR(missileguidance,debug_drawGuidanceInfo)) then {
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
    ] call FUNC(debugDraw);
};

_returnTargetPosition
