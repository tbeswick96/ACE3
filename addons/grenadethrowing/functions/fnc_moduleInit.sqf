/*
 * Author: Jonpas
 * Initializes the View Restriction module.
 *
 * Arguments:
 * 0: Logic <OBJECT>
 * 1: Synchronized Units <ARRAY>
 * 2: Module Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [logic, [unit1, unit2], true] call ace_grenadethrowing_fnc_moduleInit
 *
 * Public:
 * No
 */
#include "script_component.hpp"

if (!isServer) exitWith {};

params ["_logic", "_units", "_activated"];

if (!_activated) exitWith {};

[_logic, QGVAR(Enabled), "Enabled"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(ShowThrowArc), "ShowThrowArc"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(ShowMouseControls), "ShowMouseControls"] call EFUNC(common,readSettingFromModule);

ACE_LOGINFO_1("Grenade Throwing Module Initialized. Enabled: %1",GVAR(Enabled));
