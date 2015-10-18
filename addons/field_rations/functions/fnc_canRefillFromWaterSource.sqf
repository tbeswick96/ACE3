/*
 * Author: PabstMirror
 * Checks the conditions for being able to disarm a unit
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Item Classname <STRING>
 *
 * Return Value:
 * Can Be Refilled <BOOL>
 *
 * Example:
 * [barrel, player, "bottle"] call ace_field_rations_canRefillFromWaterSource
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_dummyTarget", "_player", "_itemClassname"];
local _cfg = configFile >> "CfgWeapons" >> _itemClassname;

((isClass _cfg) && {(getText (_cfg >> QGVAR(onRefill))) != ""})
