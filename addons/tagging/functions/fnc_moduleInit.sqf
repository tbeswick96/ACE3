/*
 * Author: Jonpas
 * Initializes the Tagging module.
 *
 * Arguments:
 * 0: The module logic <LOGIC>
 * 1: Units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

if (!isServer) exitWith {};

params ["_logic", "", "_activated"];

if (!_activated) exitWith {};

[_logic, QGVAR(quickTag), "quickTag"] call EFUNC(common,readSettingFromModule);

ACE_LOGINFO("Tagging Module Initialized.");
