/*
 * Author: Dslyecxi, Jonpas
 * Handles cooking a grenade.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Throwable <OBJECT>
 * 2: Throwable Type <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit, grenadeObject, "HandGrenade"] call ace_grenadethrowing_fnc_cook
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_grenadeItem", "_grenadeType"];

GVAR(CookingGrenade) = true;

private _activeGrenadeItemOld = GVAR(ActiveGrenadeItem);
GVAR(ActiveGrenadeItem) = _grenadeType createVehicle (position _activeGrenadeItemOld);
deleteVehicle _activeGrenadeItemOld;

// Throw Fired XEH
private _currentThrowable = (currentThrowable _unit) select 0;
private _muzzle = [_currentThrowable] call FUNC(getMuzzle);

[QGVAR(throwFiredEH), [
    _unit, // unit
    "Throw", // weapon
    _muzzle, // muzzle
    _muzzle, // mode
    GVAR(ActiveGrenadeType), // ammo
    _currentThrowable, // magazine
    GVAR(ActiveGrenadeItem) // projectile
]] call EFUNC(common,globalEvent);
