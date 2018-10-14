#include "script_component.hpp"
/*
 * Author: SilentSpike
 * Module for adjusting various aspects of zeus
 *
 * Arguments:
 * 0: The module logic <LOGIC>
 * 1: units <ARRAY>
 * 2: activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [LOGIC, [bob, kevin], true] call ace_zeus_fnc_moduleZeusSettings
 *
 * Public: No
 */

params ["_logic"];

[_logic, QGVAR(zeusAscension), "zeusAscension"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(zeusBird), "zeusBird"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(radioOrdnance), "radioOrdnance"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(revealMines), "revealMines"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(remoteWind), "remoteWind"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(autoAddObjects), "autoAddObjects"] call EFUNC(common,readSettingFromModule);
