#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Cruise missile LAUNCH stage.
 * Climbs to cruise altitude and turns toward first navigation target.
 * Transitions to WAYPOINT (if waypoints exist) or CRUISE when altitude and distance thresholds are met.
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

_attackProfileStateParams params ["", "", "_cruiseAltitude", "", "_launchPosition", "", "_waypoints"];

// Climb to cruise altitude, turn toward first navigation target
private _targetAltitudeASL = ((getTerrainHeightASL _projectilePosition) max 0) + _cruiseAltitude;

// Aim at first waypoint if set, else target
private _aimPosition = if (count _waypoints > 0) then {
    +(_waypoints#0)
} else {
    +_targetPositionASL
};
_aimPosition set [2, _targetAltitudeASL max (_aimPosition#2)];

private _returnTargetPosition = _aimPosition;

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

[_returnTargetPosition, [0, 0, 0]]
