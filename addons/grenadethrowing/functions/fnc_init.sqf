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

if (isNil QGVAR(KeyDownHandle)) then {
    GVAR(KeyDownHandle) = (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call FUNC(onKeyDown)}];
};

if (_enable) then {
    GVAR(Draw3DHandle) = addMissionEventHandler ["Draw3D", {call FUNC(draw3d);}];
    [FUNC(pfh), 0, []] call CBA_fnc_addPerFrameHandler; // Removal inside PFH
} else {
    removeMissionEventHandler ["Draw3D", GVAR(Draw3DHandle)];
    GVAR(Draw3DHandle) = nil;
};
