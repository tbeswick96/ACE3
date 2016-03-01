/*
 * Author: Dslyecxi, Jonpas
 * Mouse button down event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_onMouseButtonDown
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(Enabled) || {!GVAR(ToggleThrowMode)} || {dialog}) exitWith {};

params ["", "_key"];

if (_key == 0) exitWith {
    // Drop it, else throw it
    if (GVAR(CtrlHeld) && {!GVAR(CookingGrenade)}) then {
        [ACE_player, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);

        // Since ctrl is held, it just drops
        if (!GVAR(ThrowGrenade)) then {
            GVAR(ThrowGrenade) = true;
        };
    } else {
        if (!GVAR(ThrowGrenade)) then {
            GVAR(ThrowGrenade) = true;
        };
    };
};

if (_key == 2 && {GVAR(GrenadeInHand)} && {!GVAR(CookingGrenade)}) then {
    [ACE_player, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
    [LSTRING(Cooking)] call EFUNC(common,displayTextStructured);
};
