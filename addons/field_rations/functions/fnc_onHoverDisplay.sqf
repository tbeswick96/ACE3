/*
 * Author: PabstMirror
 * Checks the conditions for being able to disarm a unit
 *
 * Arguments:
 * 0: Target <OBJECT>
 *
 * Return Value:
 * Can Be Disarmed <BOOL>
 *
 * Example:
 * [cursorTarget] call ace_disarming_fnc_canBeDisarmed
 *
 * Public: No
 */
#include "script_component.hpp"

systemChat "onHover";

GVAR(hudInteractionHover) = true;
[0.25] call FUNC(showOverlay);
