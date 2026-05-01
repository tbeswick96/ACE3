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
if (_vSqr <= 0) exitWith {
    if (_dNow < _proxRadius) then {
        TRACE_2("prox: stationary",_dNow,_proxRadius);
        triggerAmmo _projectile;
        true
    } else { false }
};

private _tStar = -((_relPos vectorDotProduct _relVel) / _vSqr);
if (_tStar <= 0 || _tStar >= _dt) exitWith { false };

private _minPos = _relPos vectorAdd (_relVel vectorMultiply _tStar);
private _dMin = vectorMagnitude _minPos;
if (_dMin > _proxRadius) exitWith { false };

TRACE_4("prox detonation",_dNow,_dMin,_tStar,_proxRadius);
triggerAmmo _projectile;
true
