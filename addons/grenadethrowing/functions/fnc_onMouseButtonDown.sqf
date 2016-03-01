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

if (!GVAR(Enabled) || {!GVAR(ToggleThrowMode)} || {!GVAR(GrenadeInHand)} || {dialog}) exitWith {};

params ["", "_key"];

// Right mouse button
if (_key == 1) exitWith {
    if (GVAR(CookingGrenade)) then {
        GVAR(DropCookedCounter) = GVAR(DropCookedCounter) + 1;

        if (GVAR(DropCookedCounter) >= 2) then {
            ACE_player removeItem ((currentThrowable ACE_player) select 0);
            [ACE_player, "Dropping cooked grenade"] call FUNC(exitThrowMode);
        };
    } else {
        [ACE_player, "Storing grenade without throwing"] call FUNC(exitThrowMode);
    };
};

// Middle mouse button
if (_key == 2 && {!GVAR(CookingGrenade)}) then {
    [ACE_player, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
    [LSTRING(Cooking)] call EFUNC(common,displayTextStructured);
};
