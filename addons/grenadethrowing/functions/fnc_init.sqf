/*
 * Author: Dslyecxi, Jonpas
 * Enable or disable grenade throwing system.
 *
 * Arguments:
 * 0: Toggle (Enable/Disable) <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call ace_grenadethrowing_fnc_init
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_enable"];
TRACE_1("Init",_enable);

if (_enable) then {
    GVAR(Draw3DHandle) = addMissionEventHandler ["Draw3D", {call FUNC(draw3d);}];
    [FUNC(pfh), 0, []] call CBA_fnc_addPerFrameHandler; // Removal inside PFH
} else {
    removeMissionEventHandler ["Draw3D", GVAR(Draw3DHandle)];
    GVAR(Draw3DHandle) = nil;
};
