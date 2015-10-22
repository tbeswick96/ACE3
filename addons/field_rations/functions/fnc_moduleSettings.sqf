/*
 * Author: Glowbal, PabstMirror
 * Module for fieldRations settings
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 *
 * Return Value:
 * None <NIL>
 *
 * Example:
 * [logic] call ace_field_rations_fnc_moduleSettings
 *
 * Public: No
 */

#include "script_component.hpp"

if (!isServer) exitWith {};

params ["_logic"];

[_logic, QGVAR(timeWithoutWater), "timeWithoutWater"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(timeWithoutFood),  "timeWithoutFood"]  call EFUNC(common,readSettingFromModule);

if ((GVAR(timeWithoutWater) == 0) || {GVAR(timeWithoutFood) == 0}) exitWith {
    ERROR("Bad Time Setting");
};

[QGVAR(systemEnabled), true, true, true] call EFUNC(common,setSetting);

ACE_LOGINFO("Module initialised.");
