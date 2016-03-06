/*
 * Author: PabstMirror
 * Retrieve muzzle name from config.
 *
 * Arguments:
 * 0: Magazine Classname <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["magazine"] call ace_grenadethrowing_fnc_getMuzzle
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_magazineClassname"];

private _grenadeMuzzle = "";
private _throwMuzzles = getArray (configFile >> "CfgWeapons" >> "Throw" >> "muzzles");

{
    private _muzzleMagazines = getArray (configFile >> "CfgWeapons" >> "Throw" >> _x >> "magazines");

    if (_magazineClassname in _muzzleMagazines) exitWith {
        _grenadeMuzzle = _x;
    };
} forEach _throwMuzzles;

_grenadeMuzzle
