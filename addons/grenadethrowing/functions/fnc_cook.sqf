/*
 * Author: Dslyecxi, Jonpas
 * Handles cooking a grenade.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_cook
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_grenadeItem", "_grenadeType"];

GVAR(CookingGrenade) = true;

private _activeGrenadeItemOld = GVAR(ActiveGrenadeItem);
GVAR(ActiveGrenadeItem) = _grenadeType createVehicle (position _activeGrenadeItemOld);
deleteVehicle _activeGrenadeItemOld;
