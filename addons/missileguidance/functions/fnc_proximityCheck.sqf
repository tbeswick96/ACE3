#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Per-tick proximity fuze check for missiles configured with proximityFuze.
 * Computes closest-approach distance between projectile and target during
 * the current tick interval. Detonates via triggerAmmo at the sub-tick
 * closest-approach point if the minimum falls inside proximityRadius and
 * occurs within +/- one frame of now.
 *
 * Applies to any missile type whose ace_missileguidance config sets
 * proximityFuze = 1 (typically A2A: AMRAAM, ASRAAM, Sidewinder, MANPADS, SAMs).
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
_args params ["_firedEH", "_launchParams"];
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
private _relativePosition = _projectilePosition vectorDiff _targetPosition;
private _relativeVelocity = (velocity _projectile) vectorDiff (velocity _target);
private _relativeSpeedSquared = _relativeVelocity vectorDotProduct _relativeVelocity;
private _deltaTime = _timestep max 0.016;

private _currentDistance = vectorMagnitude _relativePosition;

#ifdef DRAW_GUIDANCE_INFO
private _debugDrawDistance = _proximityRadius * 20;
if (GVAR(debug_drawGuidanceInfo) && {_currentDistance < _debugDrawDistance}) then {
    private _projectilePositionAGL = ASLToAGL _projectilePosition;
    private _targetPositionAGL = ASLToAGL _targetPosition;
    drawLine3D [_projectilePositionAGL, _targetPositionAGL, [0, 1, 1, 0.5]];
    drawIcon3D ["", [0, 1, 1, 1], _projectilePositionAGL, 0, 0, 0, format ["proxR=%1 dNow=%2", _proximityRadius, _currentDistance toFixed 1], 1, 0.025, "TahomaB", "center", false, 0, -0.04];
};
#endif

if (_relativeSpeedSquared <= 0) exitWith {
    if (_currentDistance < _proximityRadius) then {
        TRACE_2("prox: stationary",_currentDistance,_proximityRadius);
        #ifdef DRAW_GUIDANCE_INFO
        if (GVAR(debug_drawGuidanceInfo)) then {
            ["#particlesource" createVehicleLocal (ASLToAGL _projectilePosition)] params ["_particleSource"];
            _particleSource setParticleParams [["\A3\Data_f\cl_basic", 8, 3, 1], "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [1.5, 1.5], [[1, 1, 0, 1], [1, 1, 0, 1], [1, 1, 0, 0]], [1], 1, 0, "", "", nil];
            _particleSource setDropInterval 0.5;
        };
        #endif
        triggerAmmo _projectile;
        END_COUNTER(proximityCheck);
        true
    } else {
        END_COUNTER(proximityCheck);
        false
    }
};

private _timeOfClosestApproach = -((_relativePosition vectorDotProduct _relativeVelocity) / _relativeSpeedSquared);
private _minimumRelativePosition = _relativePosition vectorAdd (_relativeVelocity vectorMultiply _timeOfClosestApproach);
private _minimumDistance = vectorMagnitude _minimumRelativePosition;
private _projectileVelocity = velocity _projectile;

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    private _projectileFutureAGL = ASLToAGL (_projectilePosition vectorAdd (_projectileVelocity vectorMultiply _timeOfClosestApproach));
    private _targetFutureAGL = ASLToAGL (_targetPosition vectorAdd ((velocity _target) vectorMultiply _timeOfClosestApproach));
    private _projectilePositionAGL = ASLToAGL _projectilePosition;
    drawLine3D [_projectilePositionAGL, _projectileFutureAGL, [1, 1, 0, 0.7]];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 1, 0, 1], _projectileFutureAGL, 0.4, 0.4, 0, format ["dMin=%1 tStar=%2ms", _minimumDistance toFixed 1, (_timeOfClosestApproach * 1000) toFixed 1], 1, 0.025, "TahomaB", "center", false, 0, -0.05];
    drawLine3D [_projectileFutureAGL, _targetFutureAGL, [1, 0.4, 0, [0.5, 1] select (_minimumDistance < _proximityRadius)]];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 1, 1], _targetFutureAGL, 0.4, 0.4, 0, "tgt@tStar", 1, 0.025, "TahomaB", "center", false, 0, -0.05];
};
#endif

// Genuine miss
if (_minimumDistance > _proximityRadius) exitWith { END_COUNTER(proximityCheck); false };

// Window: catch closest-approach moments within +/- one frame of now. At Mach 4 the
// moment can fall between samples (frame N: tStar > dt, frame N+1: tStar < -dt because
// the missile travelled 22m+ between them); accepting both signs catches notch/sideswipe
// cases that pure forward-looking math misses.
if (_timeOfClosestApproach > _deltaTime || {_timeOfClosestApproach < -_deltaTime}) exitWith { END_COUNTER(proximityCheck); false };

// Teleport destination: forward to closest-approach point if still approaching, or
// in-place if the moment was missed by less than one frame (don't teleport backward).
private _optimalPosition = if (_timeOfClosestApproach > 0) then {
    _projectilePosition vectorAdd (_projectileVelocity vectorMultiply _timeOfClosestApproach)
} else {
    _projectilePosition
};

// Direct-hit guard: cast missile's full frame path against target geometry. Try FIRE LOD
// first (bullet damage tracing - what hit detection actually uses); only fall back to
// GEOM if FIRE returned empty. Cast extended to 2x frame distance to catch contacts the
// missile is about to hit at the next frame boundary.
private _pathEnd = _projectilePosition vectorAdd (_projectileVelocity vectorMultiply (_deltaTime * 2));
private _matchesTarget = { (_x param [2, objNull] == _target) || {_x param [3, objNull] == _target} };
private _hits = lineIntersectsSurfaces [_projectilePosition, _pathEnd, _projectile, objNull, true, 4, "FIRE", "NONE"];
private _lodUsed = "FIRE";
if ((_hits findIf _matchesTarget) == -1) then {
    _hits = lineIntersectsSurfaces [_projectilePosition, _pathEnd, _projectile, objNull, true, 4, "GEOM", "NONE"];
    _lodUsed = "GEOM";
};
if ((_hits findIf _matchesTarget) != -1) exitWith {
    TRACE_4("prox skip: direct hit",_minimumDistance,_timeOfClosestApproach,_lodUsed,count _hits);
    #ifdef DRAW_GUIDANCE_INFO
    if (GVAR(debug_drawGuidanceInfo)) then {
        drawLine3D [ASLToAGL _projectilePosition, ASLToAGL _pathEnd, [0, 1, 0, 1]];
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 0, 1], ASLToAGL _optimalPosition, 0.6, 0.6, 0, format ["DIRECT HIT - skipping prox (dMin=%1)", _minimumDistance toFixed 1], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
    };
    #endif
    END_COUNTER(proximityCheck);
    false
};

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.4, 0, 1], ASLToAGL _optimalPosition, 0.6, 0.6, 0, format ["PROX DETONATION (dMin=%1 tStar=%2ms)", _minimumDistance toFixed 1, (_timeOfClosestApproach * 1000) toFixed 1], 1, 0.04, "TahomaB", "center", false, 0, -0.07];
};
#endif

_projectile setPosASL _optimalPosition;

#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    // persistent particle marker at the actual detonation point (red flash)
    private _detonationParticleSource = "#particlesource" createVehicleLocal (ASLToAGL _optimalPosition);
    _detonationParticleSource setParticleParams [["\A3\Data_f\cl_basic", 8, 3, 1], "", "Billboard", 1, 4, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [2, 2], [[1, 0, 0, 1], [1, 0.5, 0, 1], [1, 1, 0, 0]], [1], 1, 0, "", "", nil];
    _detonationParticleSource setDropInterval 0.5;
};
#endif

TRACE_4("prox detonation",_currentDistance,_minimumDistance,_timeOfClosestApproach,_proximityRadius);
triggerAmmo _projectile;
END_COUNTER(proximityCheck);
true
