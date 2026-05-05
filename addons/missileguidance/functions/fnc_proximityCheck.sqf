#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Per-tick proximity fuze check for missiles configured with proximityFuze.
 * Computes closest-approach distance between projectile and target across the
 * tick interval using segment-vs-segment CPA (not point/ray extrapolation), so
 * the check is robust to arbitrary tick gaps (lag spikes, low server fps).
 * Detonates via triggerAmmo at the sub-tick closest-approach point if the
 * minimum falls inside proximityRadius and occurs within the tick interval.
 *
 * Applies to any missile type whose ace_missileguidance config sets
 * proximityFuze = 1.
 *
 * Arguments:
 * 0: Guidance Arg Array <ARRAY>
 * 1: Timestep <NUMBER>
 *
 * Return Value:
 * Detonated <BOOL>
 *
 * Public: No
 */
BEGIN_COUNTER(proximityCheck);

params ["_args", "_timestep"];
_args params ["_firedEH", "_launchParams", "", "", "_stateParams"];
_firedEH params ["", "", "", "", "_ammo", "", "_projectile"];
_launchParams params ["", "_targetLaunchParams"];
_targetLaunchParams params ["_target", "", "", "", "_launchTime"];

private _config = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
if (getNumber (_config >> "proximityFuze") < 1) exitWith { END_COUNTER(proximityCheck); false };

if ((CBA_missionTime - _launchTime) < (getNumber (_config >> "proximityArmingTime"))) exitWith { END_COUNTER(proximityCheck); false };

if (isNull _target) exitWith { END_COUNTER(proximityCheck); false };

private _proximityRadius = getNumber (_config >> "proximityRadius");
private _projectilePosition = getPosASLVisual _projectile;
private _targetPosition = getPosASLVisual _target;
private _projectileVelocity = velocity _projectile;

// Recover prev-tick state from stateParams slot 6. Per-projectile namespace
// (the array is created per projectile in fnc_onFiredGetArgs), so concurrent
// missiles tracking the same target do not stomp each other's samples. On
// first call the slot is empty — seed prev = curr so the segment math
// degenerates to a point-distance check (catches sub-tick fly-throughs of
// point-blank shots that fly past within one guidance tick).
private _proximityState = _stateParams param [6, []];
_proximityState params [
    ["_prevProjectilePosition", _projectilePosition],
    ["_prevTargetPosition", _targetPosition],
    ["_prevTime", CBA_missionTime]
];
_stateParams set [6, [_projectilePosition, _targetPosition, CBA_missionTime]];

// Real elapsed gap (immune to _timestep misreport on lag spikes). Floor so
// degenerate first-tick (zero gap) falls into a sane branch.
private _realDt = (CBA_missionTime - _prevTime) max 0.001;

// Segment-vs-segment CPA. Parametrise both motions over u in [0, 1] across the
// real elapsed interval:
//   proj(u) = prevProj + (currProj - prevProj) * u
//   tgt(u)  = prevTgt  + (currTgt  - prevTgt)  * u
//   rel(u)  = r0 + dr * u   where r0 = prevProj - prevTgt, dr = (currProj-currTgt) - r0
// Minimise |rel(u)|² over u, then clamp to [0, 1] so detonation only fires for
// approaches that fall inside the actual tick interval (not extrapolated past).
private _r0 = _prevProjectilePosition vectorDiff _prevTargetPosition;
private _r1 = _projectilePosition vectorDiff _targetPosition;
private _dr = _r1 vectorDiff _r0;
private _drSq = _dr vectorDotProduct _dr;

private _u = if (_drSq > 1e-9) then {
    ((0 - (_r0 vectorDotProduct _dr)) / _drSq) max 0 min 1
} else {
    0
};

private _minimumRelativePosition = _r0 vectorAdd (_dr vectorMultiply _u);
private _minimumDistance = vectorMagnitude _minimumRelativePosition;

#ifdef DRAW_GUIDANCE_INFO
private _currentDistance = vectorMagnitude _r1;
private _debugDrawDistance = _proximityRadius * 20;
if (GVAR(debug_drawGuidanceInfo) && {_currentDistance < _debugDrawDistance}) then {
    private _projectilePositionAGL = ASLToAGL _projectilePosition;
    private _targetPositionAGL = ASLToAGL _targetPosition;
    drawLine3D [_projectilePositionAGL, _targetPositionAGL, [0, 1, 1, 0.5]];
    drawIcon3D ["", [0, 1, 1, 1], _projectilePositionAGL, 0, 0, 0, format ["proxR=%1 dNow=%2 dMin=%3 uCpa=%4", _proximityRadius, _currentDistance toFixed 1, _minimumDistance toFixed 1, _u toFixed 2], 1, 0.025, "TahomaB", "center", false, 0, -0.04];
};
#endif

// Genuine miss: closest point of segments separated by more than the fuze radius.
if (_minimumDistance > _proximityRadius) exitWith { END_COUNTER(proximityCheck); false };

// Damage-optimal teleport: project current target position onto projectile
// segment. triggerAmmo fires at the tick boundary with target at its current
// position, so minimise |opt - currTgt| directly rather than placing at the
// relative-space CPA point. Falls back to current proj if segment is degenerate
// (first-tick init state where prev = curr).
private _segment = _projectilePosition vectorDiff _prevProjectilePosition;
private _segmentSq = _segment vectorDotProduct _segment;
private _uDamage = if (_segmentSq > 1e-9) then {
    (((_targetPosition vectorDiff _prevProjectilePosition) vectorDotProduct _segment) / _segmentSq) max 0 min 1
} else {
    0
};
private _optimalPosition = _prevProjectilePosition vectorAdd (_segment vectorMultiply _uDamage);

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    private _projectileFutureAGL = ASLToAGL _optimalPosition;
    private _projectilePositionAGL = ASLToAGL _projectilePosition;
    drawLine3D [_projectilePositionAGL, _projectileFutureAGL, [1, 1, 0, 0.7]];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 0, 1], _projectileFutureAGL, 0.4, 0.4, 0, format ["dMin=%1 uCpa=%2 uDmg=%3 realDt=%4ms", _minimumDistance toFixed 1, _u toFixed 2, _uDamage toFixed 2, (_realDt * 1000) toFixed 1], 1, 0.025, "TahomaB", "center", false, 0, -0.05];
};
#endif

// Direct-hit guard: cast missile's full segment (prev → current → 2 frames
// extrapolation forward) against target geometry. Spans the gap engine
// collision may have skipped on a lag tick, plus enough lookahead to cover
// the next predicted tick even if it gets delayed. Try FIRE LOD first (bullet
// damage tracing - what hit detection actually uses); fall back to GEOM if
// FIRE returned empty.
private _pathStart = _prevProjectilePosition;
private _pathEnd = _projectilePosition vectorAdd (_projectileVelocity vectorMultiply (_realDt * 2));
private _matchesTarget = { (_x param [2, objNull] == _target) || {_x param [3, objNull] == _target} };
private _hits = lineIntersectsSurfaces [_pathStart, _pathEnd, _projectile, objNull, true, 4, "FIRE", "NONE"];
if ((_hits findIf _matchesTarget) == -1) then {
    _hits = lineIntersectsSurfaces [_pathStart, _pathEnd, _projectile, objNull, true, 4, "GEOM", "NONE"];
};
if ((_hits findIf _matchesTarget) != -1) exitWith {
    TRACE_3("prox skip: direct hit",_minimumDistance,_uDamage,count _hits);
    #ifdef DRAW_GUIDANCE_INFO
    if (GVAR(debug_drawGuidanceInfo)) then {
        drawLine3D [ASLToAGL _pathStart, ASLToAGL _pathEnd, [0, 1, 0, 1]];
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 0, 1], ASLToAGL _optimalPosition, 0.6, 0.6, 0, format ["DIRECT HIT - skipping prox (dMin=%1 uDmg=%2)", _minimumDistance toFixed 1, _uDamage toFixed 2], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
    };
    #endif
    END_COUNTER(proximityCheck);
    false
};

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.4, 0, 1], ASLToAGL _optimalPosition, 0.6, 0.6, 0, format ["PROX DETONATION (dMin=%1 uCpa=%2 uDmg=%3)", _minimumDistance toFixed 1, _u toFixed 2, _uDamage toFixed 2], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
    // persistent particle marker at the actual detonation point (red flash)
    private _detonationParticleSource = "#particlesource" createVehicleLocal (ASLToAGL _optimalPosition);
    _detonationParticleSource setParticleParams [["\A3\Data_f\cl_basic", 8, 3, 1], "", "Billboard", 1, 4, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [2, 2], [[1, 0, 0, 1], [1, 0.5, 0, 1], [1, 1, 0, 0]], [1], 1, 0, "", "", nil];
    _detonationParticleSource setDropInterval 0.5;
};
#endif

_projectile setPosASL _optimalPosition;

TRACE_3("prox detonation",_minimumDistance,_uDamage,_proximityRadius);
triggerAmmo _projectile;
END_COUNTER(proximityCheck);
true
