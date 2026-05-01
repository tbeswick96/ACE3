#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Per-tick proximity fuze check. Computes closest-approach distance between
 * the projectile and target during the current tick interval [0, dt].
 * Detonates via triggerAmmo if the minimum falls inside proximityRadius and
 * occurs strictly within this tick (so the next tick will be opening).
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
params ["_args", "_timestep"];
_args params ["_firedEH", "_launchParams"];
_firedEH params ["", "", "", "", "_ammo", "", "_projectile"];
_launchParams params ["", "_targetLaunchParams"];
_targetLaunchParams params ["_target", "", "", "", "_launchTime"];

private _config = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
if (getNumber (_config >> "proximityFuze") < 1) exitWith { false };

if ((CBA_missionTime - _launchTime) < (getNumber (_config >> "proximityArmingTime"))) exitWith { false };

if (isNull _target) exitWith { false };

private _proxRadius = getNumber (_config >> "proximityRadius");
private _projPos = getPosASLVisual _projectile;
private _targPos = getPosASLVisual _target;
private _relPos = _projPos vectorDiff _targPos;
private _relVel = (velocity _projectile) vectorDiff (velocity _target);
private _vSqr = _relVel vectorDotProduct _relVel;
private _dt = _timestep max 0.016;

private _dNow = vectorMagnitude _relPos;

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo) && {_dNow < (_proxRadius * 20)}) then {
    private _projAGL = ASLToAGL _projPos;
    private _targAGL = ASLToAGL _targPos;
    drawLine3D [_projAGL, _targAGL, [0, 1, 1, 0.5]];
    drawIcon3D ["", [0, 1, 1, 1], _projAGL, 0, 0, 0, format ["proxR=%1 dNow=%2", _proxRadius, _dNow toFixed 1], 1, 0.025, "TahomaB", "center", false, 0, -0.04];
};
#endif

if (_vSqr <= 0) exitWith {
    if (_dNow < _proxRadius) then {
        TRACE_2("prox: stationary",_dNow,_proxRadius);
        #ifdef DRAW_GUIDANCE_INFO
        if (GVAR(debug_drawGuidanceInfo)) then {
            ["#particlesource" createVehicleLocal (ASLToAGL _projPos)] params ["_PS"];
            _PS setParticleParams [["\A3\Data_f\cl_basic", 8, 3, 1], "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [1.5, 1.5], [[1, 1, 0, 1], [1, 1, 0, 1], [1, 1, 0, 0]], [1], 1, 0, "", "", nil];
            _PS setDropInterval 0.5;
        };
        #endif
        triggerAmmo _projectile;
        true
    } else { false }
};

private _tStar = -((_relPos vectorDotProduct _relVel) / _vSqr);
private _minPos = _relPos vectorAdd (_relVel vectorMultiply _tStar);
private _dMin = vectorMagnitude _minPos;
private _projVel = velocity _projectile;

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    private _projFutureAGL = ASLToAGL (_projPos vectorAdd (_projVel vectorMultiply _tStar));
    private _targFutureAGL = ASLToAGL (_targPos vectorAdd ((velocity _target) vectorMultiply _tStar));
    private _projAGL = ASLToAGL _projPos;
    drawLine3D [_projAGL, _projFutureAGL, [1, 1, 0, 0.7]];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 0, 1], _projFutureAGL, 0.4, 0.4, 0, format ["dMin=%1 tStar=%2ms", _dMin toFixed 1, (_tStar * 1000) toFixed 1], 1, 0.025, "TahomaB", "center", false, 0, -0.05];
    drawLine3D [_projFutureAGL, _targFutureAGL, [1, 0.4, 0, [0.5, 1] select (_dMin < _proxRadius)]];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 1, 1], _targFutureAGL, 0.4, 0.4, 0, "tgt@tStar", 1, 0.025, "TahomaB", "center", false, 0, -0.05];
};
#endif

// Genuine miss
if (_dMin > _proxRadius) exitWith { false };

// Window: catch the closest-approach moment within +/- one frame of now. At Mach 4
// the moment can fall between samples (frame N: tStar > dt, frame N+1: tStar < -dt
// because the missile travelled 22m+ between them); accepting both signs catches the
// notch/sideswipe case that pure forward-looking math misses.
if (_tStar > _dt || _tStar < -_dt) exitWith { false };

// Compute teleport destination: forward to closest-approach point if still approaching,
// or in-place if the moment was missed by less than one frame (don't teleport backward).
private _optimalPos = if (_tStar > 0) then {
    _projPos vectorAdd (_projVel vectorMultiply _tStar)
} else {
    _projPos
};

// Direct-hit guard: cast missile's full frame path against target geometry. Try FIRE LOD
// first (bullet damage tracing - what hit detection actually uses); only fall back to
// GEOM if FIRE returned empty. Cast extended to 2x frame distance to catch contacts the
// missile is about to hit at the next frame boundary.
private _pathEnd = _projPos vectorAdd (_projVel vectorMultiply (_dt * 2));
private _matchesTarget = { (_x param [2, objNull] == _target) || {_x param [3, objNull] == _target} };
private _hits = lineIntersectsSurfaces [_projPos, _pathEnd, _projectile, objNull, true, 4, "FIRE", "NONE"];
private _lodUsed = "FIRE";
if ((_hits findIf _matchesTarget) == -1) then {
    _hits = lineIntersectsSurfaces [_projPos, _pathEnd, _projectile, objNull, true, 4, "GEOM", "NONE"];
    _lodUsed = "GEOM";
};
if ((_hits findIf _matchesTarget) != -1) exitWith {
    TRACE_4("prox skip: direct hit",_dMin,_tStar,_lodUsed,count _hits);
    #ifdef DRAW_GUIDANCE_INFO
    if (GVAR(debug_drawGuidanceInfo)) then {
        drawLine3D [ASLToAGL _projPos, ASLToAGL _pathEnd, [0, 1, 0, 1]];
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 0, 1], ASLToAGL _optimalPos, 0.6, 0.6, 0, format ["DIRECT HIT - skipping prox (dMin=%1)", _dMin toFixed 1], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
    };
    #endif
    false
};

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.4, 0, 1], ASLToAGL _optimalPos, 0.6, 0.6, 0, format ["PROX DETONATION (dMin=%1 tStar=%2ms)", _dMin toFixed 1, (_tStar * 1000) toFixed 1], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
};
#endif

_projectile setPosASL _optimalPos;

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    // persistent particle marker at the actual detonation point (red flash)
    private _detPS = "#particlesource" createVehicleLocal (ASLToAGL _optimalPos);
    _detPS setParticleParams [["\A3\Data_f\cl_basic", 8, 3, 1], "", "Billboard", 1, 4, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [2, 2], [[1, 0, 0, 1], [1, 0.5, 0, 1], [1, 1, 0, 0]], [1], 1, 0, "", "", nil];
    _detPS setDropInterval 0.5;
};
#endif

TRACE_4("prox detonation",_dNow,_dMin,_tStar,_proxRadius);
triggerAmmo _projectile;
true
