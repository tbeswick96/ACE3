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

private _pylons = configProperties [configFile >> "CfgVehicles" >> typeOf GVAR(currentAircraft) >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"];
private _originalPylonMagazines = getPylonMagazines GVAR(currentAircraft);

{
    if (isText (configFile >> "CfgMagazines" >> (_originalPylonMagazines select _forEachIndex) >> "pylonWeapon")) then {
        private _weapon = getText (configFile >> "CfgMagazines" >> (_originalPylonMagazines select _forEachIndex) >> "pylonWeapon");
        GVAR(currentAircraft) removeWeaponTurret [_weapon, [0]];
        GVAR(currentAircraft) removeWeaponTurret [_weapon, [-1]];
    };
    
    private _pylon = (_x select 0) lbData (lbCurSel (_x select 0));
    private _pylonMagazines = getPylonMagazines GVAR(currentAircraft);
    private _turret = getArray ((_pylons select _forEachIndex) >> "turret");
    if (GVAR(makeNewPylonsEmpty)) then {
        if ((_pylonMagazines select _forEachIndex) != _pylon) then {
            GVAR(currentAircraft) setPylonLoadout [_forEachIndex + 1, _pylon, true, _turret];
            GVAR(currentAircraft) setAmmoOnPylon [_forEachIndex + 1, 0];
        };
    } else {
        private _count = [configFile >> "CfgMagazines" >> _pylon >> "count", "number", 0] call CBA_fnc_getConfigEntry;
        GVAR(currentAircraft) setPylonLoadout [_forEachIndex + 1, _pylon, true, _turret];
        GVAR(currentAircraft) setAmmoOnPylon [_forEachIndex + 1, _count];
    };
} forEach GVAR(comboBoxes);

private _pylonMagazines = getPylonMagazines GVAR(currentAircraft);
{
    private _turret = getArray ((_pylons select _forEachIndex) >> "turret");
    private _ammo = ((GVAR(currentAircraft) ammoOnPylon (_forEachIndex + 1)));
    GVAR(currentAircraft) setPylonLoadout [(_forEachIndex + 1), _x, true, _turret];
    GVAR(currentAircraft) setAmmoOnPylon [(_forEachIndex + 1), _ammo];
} forEach _pylonMagazines;

[GVAR(currentAircraft)] call uksf_gear_fnc_correctPilotPylon;
