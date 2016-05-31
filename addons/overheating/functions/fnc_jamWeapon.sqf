/*
 * Author: Commy2, based on KK_fnc_playerWeaponMulfunction from KillzoneKid
 * Jam the weapon
 *
 * Argument:
 * 0: Unit <OBJECT>
 * 1: Weapon <STRING>
 *
 * Return value:
 * None
 *
 * Example:
 * [player, currentWeapon player] call ace_overheating_fnc_jamWeapon
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_weapon"];
TRACE_2("params",_unit,_weapon);

// don't jam a weapon with no rounds left
private _ammo = _unit ammo _weapon;
if (_ammo == 0) exitWith {};

private _jammedWeapons = _unit getVariable [QGVAR(jammedWeapons), []];
_jammedWeapons pushBack _weapon;

_unit setVariable [QGVAR(jammedWeapons), _jammedWeapons];



// Stop current burst
if (_ammo > 0) then {
    _unit setAmmo [_weapon, 0];
    // this is to re-activate the 'DefaultAction', so you can jam a weapon while full auto shootin
    [{
        params ["_unit", "_weapon", "_ammo"];
        _unit setAmmo [_weapon, _ammo];
    }, [_unit, _weapon, _ammo]] call CBA_fnc_execNextFrame;
};

// only display the hint once, after you try to shoot an already jammed weapon
GVAR(knowAboutJam) = false;

["weaponJammed", [_unit,_weapon]] call EFUNC(common,localEvent);


if (_unit getVariable [QGVAR(JammingActionID), -1] == -1) then {

    private _condition = {
        [_this select 1] call CBA_fnc_canUseWeapon
        && {currentMuzzle (_this select 1) in ((_this select 1) getVariable [QGVAR(jammedWeapons), []])}
        && {!(currentMuzzle (_this select 1) in ((_this select 1) getVariable [QEGVAR(safemode,safedWeapons), []]))}
    };

    private _statement = {
        playSound3D ["a3\sounds_f\weapons\Other\dry9.wss", _this select 0];

        if (!(missionNamespace getVariable [QGVAR(knowAboutJam), false]) && {(_this select 1) ammo currentWeapon (_this select 1) > 0} && {GVAR(DisplayTextOnJam)}) then {
            [localize LSTRING(WeaponJammed)] call EFUNC(common,displayTextStructured);
            GVAR(knowAboutJam) = true;
        };
    };

    private _id = [_unit, "DefaultAction", _condition, _statement] call EFUNC(common,addActionEventHandler);

    _unit setVariable [QGVAR(JammingActionID), _id];
};
