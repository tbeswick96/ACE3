#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Adds ACE interaction menu action for cruise planner.
 * Follows the Hellfire setupVehicle pattern.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ace_missileguidance_fnc_cruise_missile_setupVehicle
 *
 * Public: No
 */
params ["_player"];
private _vehicle = vehicle _player;

if (_vehicle == _player) exitWith {};
if (_vehicle getVariable [QGVAR(cruise_missile_actionsAdded), false]) exitWith {};

// Check if any weapon on the vehicle turret has cruise missile enabled
private _turretPath = if (_player == (driver _vehicle)) then {[-1]} else {_player call CBA_fnc_turretPath};
private _hasCruiseMissile = (_vehicle weaponsTurret _turretPath) findIf {
    private _weapon = _x;
    (getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")) findIf {
        private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
        private _ammoAttackProfiles = getArray (configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON) >> "attackProfiles");
        "cruise_missile" in _ammoAttackProfiles
    } > -1
} > -1;

if (!_hasCruiseMissile) exitWith {};

_vehicle setVariable [QGVAR(cruise_missile_actionsAdded), true];
TRACE_2("adding cruise missile planner action",_player,typeOf _vehicle);

// Set default cruise mode if not already set
if (isNil {_vehicle getVariable QGVAR(cruiseMode)}) then {
    _vehicle setVariable [QGVAR(cruiseMode), "high_tf", true];
};

// Cruise Planner action
private _plannerAction = [QGVAR(cruisePlanner), "Cruise Planner", "", {
    createDialog QGVAR(cruisePlannerUI);
}, {true}] call EFUNC(interact_menu,createAction);
[_vehicle, 1, ["ACE_SelfActions"], _plannerAction] call EFUNC(interact_menu,addActionToObject);
