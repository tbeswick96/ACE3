#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Dialog onUnload handler. Tears down PFHs + spectator camera.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * Called automatically via dialog onUnload
 *
 * Public: No
 */

if (GVAR(activeVitalsPFH) != -1) then {
    [GVAR(activeVitalsPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(activeVitalsPFH) = -1;
};

if (GVAR(activeSpectatorPFH) != -1) then {
    [GVAR(activeSpectatorPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(activeSpectatorPFH) = -1;
};

[] call FUNC(spectatorCleanup);
