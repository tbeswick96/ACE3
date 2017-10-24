/*
 * Author: Glowbal
 * Check if unit has item. Note: case-sensitive.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Item Classname <STRING>
 *
 * Return Value:
 * Unit has Item <BOOL>
 *
 * Example:
 * [bob, "item"] call ace_common_fnc_hasItem
 *
 * Public: Yes
 */
#include "script_component.hpp"

params [["_unit", objNull, [objNull]], ["_item", "", [""]]];

_item in items _unit
