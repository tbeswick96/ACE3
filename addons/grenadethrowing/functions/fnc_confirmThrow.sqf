/*
 * Author: Dslyecxi, Jonpas
 * Confirms throw and lobs the grenade.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_confirmThrow
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

if (GVAR(CtrlHeld) && {!GVAR(CookingGrenade)}) then {
    [_unit, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
};

_unit playAction "ThrowGrenade";

// Delay for animation
[FUNC(throw), [_unit], 0.3] call EFUNC(common,waitAndExecute);
