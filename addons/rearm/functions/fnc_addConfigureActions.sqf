/*
 * Author: Tim Beswick
 * Adds actions for pylon configuration.
 *
 * Arguments:
 * 0: Target <OBJECT>
 *
 * Return Value:
 * ChildActions <ARRAY>
 *
 * Example:
 * [tank] call ace_rearm_fnc_addConfigureActions
 *
 * Public: No
 */
#include "script_component.hpp"

params [["_truck", objNull, [objNull]]];

private _vehicles = nearestObjects [_truck, ["AllVehicles"], 20];
_vehicles = _vehicles select {(_x != _truck) && {!(_x isKindOf "CAManBase")} && {!(_x getVariable [QGVAR(disabled), false])} && {isClass (configFile >> "CfgVehicles" >> typeOf _x >> "Components" >> "TransportPylonsComponent")}};

private _vehicleActions = [];
{
    private _vehicle = _x;
    private _loadoutAction = [
        QEGVAR(aircraft,loadoutAction),
        getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"),
        getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "Icon"),
        {(_this select 2) call EFUNC(aircraft,showDialog)},
        {true},
        {},
        _vehicle
    ] call EFUNC(interact_menu,createAction);
    _vehicleActions pushBack [_loadoutAction, [], _truck];

    false
} count _vehicles;

_vehicleActions
