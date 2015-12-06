/*
 * Author: commy2
 * Get the muzzles of a weapon.
 *
 * Arguments:
 * 0: Weapon <STRING>
 *
 * Return Value:
 * All weapon muzzles <ARRAY>
 *
 * Public: Yes
 */
#include "script_component.hpp"

params [["_weapon", "", [""]]];

private _muzzles = [];

{
    _muzzles pushBack ([_x, _weapon] select (_x == "this"));
    false
} count getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");

_muzzles
