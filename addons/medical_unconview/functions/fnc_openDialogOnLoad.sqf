#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Dialog onLoad handler. Default class visibility opens with the Health tab content
 * already shown. Starts the vitals PFH so values populate immediately.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * Called automatically via dialog onLoad
 *
 * Public: No
 */

GVAR(currentTab) = "health";

GVAR(activeVitalsPFH) = [FUNC(vitalsUpdate), 0.5, []] call CBA_fnc_addPerFrameHandler;

[[], -1] call FUNC(vitalsUpdate);
