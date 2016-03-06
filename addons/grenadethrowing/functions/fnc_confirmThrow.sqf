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

// If Ctrl is held, we don't delay, otherwise we wait for the playAction to complete, which is roughly 0.3 seconds
private _waitTime = [0.3, 0] select GVAR(CtrlHeld);

[FUNC(throw), [_unit], _waitTime] call EFUNC(common,waitAndExecute);
