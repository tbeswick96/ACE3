#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Cruise missile CRUISE stage.
 * Used when no waypoints and no attack direction — beeline to target with terrain following.
 * Transitions to POPUP when within popup transition distance.
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

_attackProfileStateParams params ["", "", "_cruiseAltitude", "", "", "_lastDesiredAltitude"];

// Only used when no waypoints and no attack direction — beeline to target
// Sample terrain along curved path from velocity toward target
private _terrainFollowAimDirection = vectorNormalized [_targetPositionASL#0 - _projectilePosition#0, _targetPositionASL#1 - _projectilePosition#1, 0];
private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(terrainFollowSmooth);
_attackProfileStateParams set [5, _smoothedAltitude];

private _returnTargetPosition = [_targetPositionASL, _smoothedAltitude, _projectilePosition, _velocityDirection, _pitchRate, _speed] call FUNC(terrainFollowAimPoint);

if (_horizontalDistance < _popupTransitionDistance) then {
    // Lock heading from missile to target (no configured attack dir in CRUISE)
    private _deltaX = _targetPositionASL#0 - _projectilePosition#0;
    private _deltaY = _targetPositionASL#1 - _projectilePosition#1;
    _gpsData set [2, (_deltaX atan2 _deltaY + 360) % 360];
    _attackProfileStateParams set [0, STAGE_POPUP];
};

[_returnTargetPosition, _terrainFollowAimDirection]
