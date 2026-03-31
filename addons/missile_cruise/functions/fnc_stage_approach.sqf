#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Cruise missile APPROACH stage.
 * Flies along the attack direction toward the target with terrain following.
 * Uses line-tracking to converge onto the attack line through the target.
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

// Sample terrain along curved path from velocity toward attack direction
private _terrainFollowAimDirection = _attackDirectionVector;
private _smoothedAltitude = [_projectilePosition, _velocityDirection, _terrainFollowAimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed, _lastDesiredAltitude] call FUNC(terrainFollowSmooth);
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

private _returnTargetPosition = _aimPosition;

// Pop up at the computed transition distance. The popup stage handles residual
// heading and cross-track correction during climb, so delaying for perfect
// alignment risks running out of room for the pull-up at high impact angles.
if (_horizontalDistance < _popupTransitionDistance) then {
    _attackProfileStateParams set [0, STAGE_POPUP];
};

[_returnTargetPosition, _terrainFollowAimDirection]
