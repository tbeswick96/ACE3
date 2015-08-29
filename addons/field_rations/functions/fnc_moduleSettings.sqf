/*
 * Author: PabstMirror
 * Module for fieldRations settings
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 *
 * Return Value:
 * None <NIL>
 *
 * Public: No
 */

#include "script_component.hpp"

if (!isServer) exitWith {};

PARAMS_1(_logic);

[_logic, QGVAR(timeWithoutWater), "timeWithoutWater"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(timeWithoutFood),  "timeWithoutFood"]  call EFUNC(common,readSettingFromModule);

if ((GVAR(timeWithoutWater) == 0) || {GVAR(timeWithoutFood) == 0}) exitWith {
    ERROR("Bad Time Setting");
};

[QGVAR(systemEnabled), true, false, true] call EFUNC(common,setSetting);

diag_log text format ["[ACE] - Field Rations Module initialised"];
