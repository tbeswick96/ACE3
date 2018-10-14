#include "script_component.hpp"
/*
 * Author: Ruthberg
 * Toggles the coriolis and spin drift output on/off
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_atragmx_fnc_toggle_coriolis
 *
 * Public: No
 */

GVAR(showCoriolis) = !GVAR(showCoriolis);
true call FUNC(show_main_page);
