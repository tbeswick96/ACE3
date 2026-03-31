#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Cruise missile TERMINAL stage.
 * Terminal dive along impact line (JDAM-style line navigation).
 * Aim is always ON the impact line, at (distance - lead) from target.
 * This pulls the missile onto the line and maintains correct attack angle.
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

// Terminal dive along impact line (JDAM-style line navigation).
// Aim is always ON the impact line, at (distance - lead) from target.
// This pulls the missile onto the line and maintains correct attack angle.
// If seeker provides an updated target (e.g. SALH laser spot), use it
if (_seekerTargetPosition isNotEqualTo [0,0,0] && {_seekerTargetPosition isNotEqualTo _targetPositionASL}) then {
    _targetPositionASL = _seekerTargetPosition;
    _distanceToTarget = _projectilePosition vectorDistance _targetPositionASL;
    _horizontalDistance = [_projectilePosition#0, _projectilePosition#1, 0] vectorDistance [_targetPositionASL#0, _targetPositionASL#1, 0];
};

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

private _returnTargetPosition = _aimPosition;
_targetData set [2, _projectilePosition vectorDistance _aimPosition];

[_returnTargetPosition, [0, 0, 0]]
