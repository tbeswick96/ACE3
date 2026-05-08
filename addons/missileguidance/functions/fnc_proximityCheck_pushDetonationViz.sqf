#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Push a 5-second persistent debug viz package for a prox-fuze detonation.
 * Drawn each frame by the PFEH registered in XEH_postInit.sqf.
 *
 * Visualises:
 *   magenta  prev → current  projectile motion (observed)
 *   cyan     prev → current  target motion     (observed)
 *   yellow   current → predicted-next  projectile/target motion (extrapolated)
 *   orange/red sphere at projectile-position-at-CPA (orange = backward, red = forward)
 *   white sphere at target-position-at-CPA
 *   green line connecting the two CPA positions (the closest approach itself)
 *   text label with case, u, dist, radius, realDt, accel magnitudes
 *
 * Arguments:
 * 0:  Case label "BACKWARD" | "FORWARD" <STRING>
 * 1:  Projectile position at CPA (ASL) <ARRAY>
 * 2:  Target position at CPA (ASL) <ARRAY>
 * 3:  CPA u parameter (clamped 0..1) <NUMBER>
 * 4:  CPA distance <NUMBER>
 * 5:  Previous projectile position (ASL) <ARRAY>
 * 6:  Current projectile position (ASL) <ARRAY>
 * 7:  Previous target position (ASL) <ARRAY>
 * 8:  Current target position (ASL) <ARRAY>
 * 9:  Predicted-next projectile position (ASL) <ARRAY>
 * 10: Predicted-next target position (ASL) <ARRAY>
 * 11: Proximity radius <NUMBER>
 * 12: Real elapsed dt this tick <NUMBER>
 * 13: Projectile acceleration EMA <ARRAY>
 * 14: Target acceleration EMA <ARRAY>
 *
 * Public: No
 */
if (!hasInterface || {!GVAR(debug_drawGuidanceInfo)}) exitWith {};

params [
    "_caseLabel",
    "_projectilePositionAtCPA", "_targetPositionAtCPA",
    "_cpaTimeClamped", "_cpaDistance",
    "_previousProjectilePosition", "_currentProjectilePosition",
    "_previousTargetPosition", "_currentTargetPosition",
    "_predictedNextProjectilePosition", "_predictedNextTargetPosition",
    "_proximityRadius", "_realDt",
    "_projectileAccelerationEMA", "_targetAccelerationEMA"
];

private _expireTime = CBA_missionTime + PROXIMITY_DEBUG_DRAW_TTL_DETONATION;
private _detonationColor = if (_caseLabel == "BACKWARD") then { [1, 0.5, 0, 1] } else { [1, 0, 0, 1] };

private _projectileAccelerationMagnitude = vectorMagnitude _projectileAccelerationEMA;
private _targetAccelerationMagnitude = vectorMagnitude _targetAccelerationEMA;
private _label = format [
    "%1 CPA  u=%2  dist=%3 / radius=%4  realDt=%5ms  projAccel=%6  tgtAccel=%7",
    _caseLabel,
    _cpaTimeClamped toFixed 2,
    _cpaDistance toFixed 2,
    _proximityRadius toFixed 1,
    (_realDt * 1000) toFixed 1,
    _projectileAccelerationMagnitude toFixed 3,
    _targetAccelerationMagnitude toFixed 3
];

// Observed motion: prev -> current
GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [1, 0, 1, 1]];
}, [_previousProjectilePosition, _currentProjectilePosition]];

GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [0, 1, 1, 1]];
}, [_previousTargetPosition, _currentTargetPosition]];

// Predicted next-tick motion: current -> predicted next
GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [1, 1, 0, 0.7]];
}, [_currentProjectilePosition, _predictedNextProjectilePosition]];

GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [1, 1, 0, 0.7]];
}, [_currentTargetPosition, _predictedNextTargetPosition]];

// Closest-approach segment (between projectile and target at CPA moment)
GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [0, 1, 0, 1]];
}, [_projectilePositionAtCPA, _targetPositionAtCPA]];

// Projectile detonation sphere
GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_position", "_color", "_label"];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", _color, ASLToAGL _position, 0.6, 0.6, 0, _label, 1, 0.04, "TahomaB", "center", false, 0, -0.07];
}, [_projectilePositionAtCPA, _detonationColor, _label]];

// Target position at CPA marker (white sphere, smaller)
GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_position"];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 1, 1], ASLToAGL _position, 0.4, 0.4, 0, "tgt @ CPA", 1, 0.025, "TahomaB"];
}, [_targetPositionAtCPA]];
