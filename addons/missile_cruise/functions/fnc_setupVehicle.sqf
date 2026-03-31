#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Adds ACE interaction menu action for cruise planner.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ace_missile_cruise_fnc_setupVehicle
 *
 * Public: No
 */
params ["_player"];
private _vehicle = vehicle _player;

if (_vehicle == _player) exitWith {};
if (_vehicle getVariable [QGVAR(actionsAdded), false]) exitWith {};
_vehicle setVariable [QGVAR(actionsAdded), true];
TRACE_2("adding cruise missile planner action",_player,typeOf _vehicle);

// Cruise Planner action - condition checks turret weapons (cached per weapon)
private _condition = {
    params ["_target", "_player"];
    private _turretPath = if (_player == (driver _target)) then {[-1]} else {_player call CBA_fnc_turretPath};
    private _hasCruiseMissile = (_target weaponsTurret _turretPath) findIf {
        private _weapon = _x;
        GVAR(weapons) getOrDefaultCall [_weapon, {
            (getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")) findIf {
                private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                private _ammoAttackProfiles = getArray (configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON) >> "attackProfiles");
                "cruise_missile" in _ammoAttackProfiles
            } > -1
        }, true]
    } > -1;
    _hasCruiseMissile
};

private _plannerAction = [QGVAR(cruisePlanner), "Cruise Planner", "", {
    createDialog QGVAR(cruisePlannerUI);
}, _condition] call EFUNC(interact_menu,createAction);
[_vehicle, 1, ["ACE_SelfActions"], _plannerAction] call EFUNC(interact_menu,addActionToObject);
