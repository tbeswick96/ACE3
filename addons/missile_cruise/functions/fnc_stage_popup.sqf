#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Cruise missile POPUP stage.
 * Climbs to popup altitude for terminal dive.
 * Aims along attack line at popup altitude, converging to above-target as we close in.
 * Transitions to TERMINAL when physics-based terminal distance is reached.
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

private _returnTargetPosition = _popupAimPosition;

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

[_returnTargetPosition, [0, 0, 0]]
