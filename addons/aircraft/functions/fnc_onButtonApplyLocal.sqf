/*
 * Author: 654wak654
 * Applies the current configuration of pylons to the aircraft
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_aircraft_fnc_onButtonApply
 *
 * Public: No
 */
#include "script_component.hpp"

params [["_vehicle", objNull], ["_combos", []]];

if (!local _vehicle) exitWith {
    [QGVAR(onButtonApplyLocal), [_vehicle, _combos], _vehicle] call CBA_fnc_targetEvent;
};

private _pylons = configProperties [configFile >> "CfgVehicles" >> typeOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"];
private _originalPylonMagazines = getPylonMagazines _vehicle;

{
    if (isText (configFile >> "CfgMagazines" >> (_originalPylonMagazines select _forEachIndex) >> "pylonWeapon")) then {
        private _weapon = getText (configFile >> "CfgMagazines" >> (_originalPylonMagazines select _forEachIndex) >> "pylonWeapon");
        _vehicle removeWeaponTurret [_weapon, [0]];
        _vehicle removeWeaponTurret [_weapon, [-1]];
    };
    
    private _pylon = (_x select 0) lbData (lbCurSel (_x select 0));
    private _pylonMagazines = getPylonMagazines _vehicle;
    private _turret = getArray ((_pylons select _forEachIndex) >> "turret");
    if (GVAR(makeNewPylonsEmpty)) then {
        if ((_pylonMagazines select _forEachIndex) != _pylon) then {
            _vehicle setPylonLoadout [_forEachIndex + 1, _pylon, true, _turret];
            _vehicle setAmmoOnPylon [_forEachIndex + 1, 0];
        };
    } else {
        private _count = [configFile >> "CfgMagazines" >> _pylon >> "count", "number", 0] call CBA_fnc_getConfigEntry;
        _vehicle setPylonLoadout [_forEachIndex + 1, _pylon, true, _turret];
        _vehicle setAmmoOnPylon [_forEachIndex + 1, _count];
    };
} forEach _combos;

private _pylonMagazines = getPylonMagazines _vehicle;
{
    private _turret = getArray ((_pylons select _forEachIndex) >> "turret");
    private _ammo = ((_vehicle ammoOnPylon (_forEachIndex + 1)));
    _vehicle setPylonLoadout [(_forEachIndex + 1), _x, true, _turret];
    _vehicle setAmmoOnPylon [(_forEachIndex + 1), _ammo];
} forEach _pylonMagazines;

[_vehicle] call uksf_gear_fnc_correctPilotPylon;
