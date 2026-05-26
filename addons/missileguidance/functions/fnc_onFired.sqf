#include "..\script_component.hpp"
/*
 * Author: jaynus / nou
 * Fired event handler, starts guidance if enabled for ammo
 *
 * Arguments:
 * 0: Shooter (Man/Vehicle) <OBJECT>
 * 1: Weapon (not used) <STRING>
 * 2: Muzzle (not used) <STRING>
 * 3: Mode (not used) <STRING>
 * 4: Ammo <STRING>
 * 5: Magazine (not used) <STRING>
 * 6: Projectile <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "", "", "", "ACE_Javelin_FGM148", "", theMissile] call ace_missileguidance_fnc_onFired;
 *
 * Public: No
 */

params ["_shooter", "", "", "", "_ammo", "", "_projectile"];

private _configAmmo = configFile >> "CfgAmmo" >> _ammo;

// Bail if guidance is disabled for this ammo
if ((getNumber (_configAmmo >> QUOTE(ADDON) >> "enabled")) != 1) exitWith {};

// Bail on locality of the projectile, it should be local to us
if (GVAR(enabled) < 1 || {!local _projectile} ) exitWith {};

// Bail if shooter isn't player AND system not enabled for AI:
if ( !isPlayer _shooter && { GVAR(enabled) < 2 } ) exitWith {};

// Verify ammo has explicity added guidance config (ignore inheritances)
private _configs = QUOTE(configName _x == QUOTE(QUOTE(ADDON))) configClasses _configAmmo;
if (_configs isEqualTo []) exitWith {};

private _args = call FUNC(onFiredGetArgs);

// UKSF AAM telemetry: structured fire+impact log for Meteor, AIM-120 family, ASRAAM.
// Grep `[uksf_aam]` in server/client RPT to reconstruct engagement timelines.
private _isTrackedAAM = _ammo == "rksla3_ammo_meteor"
    || {_ammo isKindOf ["ammo_Missile_AMRAAM_D", configFile >> "CfgAmmo"]}
    || {_ammo isKindOf ["ammo_Missile_AMRAAM_C", configFile >> "CfgAmmo"]}
    || {_ammo isKindOf ["M_Air_AA", configFile >> "CfgAmmo"]};
if (_isTrackedAAM) then {
    // Pull the target guidance actually resolved (vanilla-lock fallback via
    // missileTarget / assignedTarget) out of the launch params — single source of
    // truth. _args[1][1][0] == _target per the layout comment in onFiredGetArgs.
    private _target = _args select 1 select 1 select 0;
    private _shooterVehicle = vehicle _shooter;
    private _shooterName = if (isPlayer _shooter) then { name _shooter } else { typeOf _shooter };
    private _targetType = if (isNull _target) then { "" } else { typeOf _target };
    private _range = if (isNull _target) then { -1 } else { _shooterVehicle distance _target };
    private _fireTime = CBA_missionTime;
    diag_log format ["[uksf_aam] fired t=%1 ammo=%2 shooter=%3 target=%4 range=%5m alt=%6m",
        _fireTime toFixed 3, _ammo, _shooterName, _targetType,
        _range toFixed 0, ((getPosASL _shooterVehicle) select 2) toFixed 0];
    _projectile setVariable ["uksf_aam_ctx", [_shooterName, _ammo, _target, _targetType, _fireTime]];
    _projectile addEventHandler ["Explode", {
        params ["_proj"];
        private _ctx = _proj getVariable ["uksf_aam_ctx", []];
        if (_ctx isEqualTo []) exitWith {};
        _ctx params ["_shooterName", "_ammo", "_target", "_targetType", "_fireTime"];
        private _explodeTime = CBA_missionTime;
        private _cpa = if (isNull _target) then { -1 } else { _proj distance _target };
        // 1s wait so frag HD events land before we read damage.
        [{
            params ["_shooterName", "_ammo", "_target", "_targetType", "_fireTime", "_explodeTime", "_cpa"];
            private _dmg = if (isNull _target) then { -1 } else { damage _target };
            private _killed = !isNull _target && {!alive _target || _dmg >= 0.9};
            diag_log format ["[uksf_aam] impact t=%1 ammo=%2 shooter=%3 target=%4 cpa=%5m flightT=%6s dmg=%7 killed=%8",
                _explodeTime toFixed 3, _ammo, _shooterName, _targetType,
                _cpa toFixed 1, (_explodeTime - _fireTime) toFixed 2,
                _dmg toFixed 2, _killed];
        }, [_shooterName, _ammo, _target, _targetType, _fireTime, _explodeTime, _cpa], 1] call CBA_fnc_waitAndExecute;
    }];
};

[LINKFUNC(guidancePFH),0, _args] call CBA_fnc_addPerFrameHandler;

if (GVAR(debug_enableMissileCamera)) then {
    [_projectile] call FUNC(dev_ProjectileCamera);
};
