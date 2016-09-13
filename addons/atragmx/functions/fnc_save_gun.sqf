/*
 * Author: Ruthberg
 * Saves the currently select gun profile into the profileNamespace
 *
 * Arguments:
 * Nothing
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ace_atragmx_fnc_save_gun
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_index"];
_index = 0 max (lbCurSel 6000);

GVAR(gunList) set [_index, +GVAR(workingMemory)];

lbClear 6000;
{
    lbAdd [6000, _x select 0];
} forEach GVAR(gunList);

profileNamespace setVariable ["ACE_ATragMX_gunList", GVAR(gunList)];
