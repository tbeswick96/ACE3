/*
 * Author: Glowbal
 * Get whatever or not a unit should be or stay unconscious.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * ReturnValue:
 * Should the unit stay unconscious? <BOOL>
 *
 * Public: Yes
 */

#include "script_component.hpp"

params ["_unit"];

if (isnil QGVAR(unconsciousConditions)) then {
    GVAR(unconsciousConditions) = [];
};

private _return = false;
{
    if ((_x isEqualType {}) && {([_unit] call _x)}) exitwith {
       _return = true;
    };
} foreach GVAR(unconsciousConditions);

_return
