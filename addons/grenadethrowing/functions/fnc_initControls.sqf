/*
 * Author: Dslyecxi, Jonpas
 * Initializes or deinitializes controls.
 *
 * Arguments:
 * 0: Initialize/Deinitialize Controls <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call ace_grenadethrowing_fnc_initControls
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_enable"];

if (_enable) then {
    GVAR(KeyDownHandle) = (findDisplay 46) displayAddEventHandler ["KeyDown", {_this call FUNC(onKeyDown)}];
    GVAR(MouseButtonDownHandle) = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {_this call FUNC(onMouseButtonDown)}];
    GVAR(MouseScrollHandle) = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {_this call FUNC(onMouseScroll)}];
} else {
    (findDisplay 46) displayRemoveEventHandler ["KeyDown", GVAR(KeyDownHandle)];
    (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", GVAR(MouseButtonDownHandle)];
    (findDisplay 46) displayRemoveEventHandler ["MouseZChanged", GVAR(MouseScrollHandle)];
};
