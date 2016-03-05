/*
 * Author: Jonpas
 * Key up event.
 *
 * Arguments:
 * 0: Control <CONTROL>
 * 1: Key <NUMBER>
 * 2: Shift <BOOL>
 * 3: Ctrl <BOOL>
 * 4: Alt <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [control, 5, false, true, false] call ace_grenadethrowing_fnc_onKeyUp
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(GrenadeInHand) || {call EFUNC(common,isFeatureCameraActive)}) exitWith {false};

params ["", "_key", "_shift", "_ctrl", "_alt"];

// Extend arm drop mode (only on foot)
if (vehicle ACE_player == ACE_player && {_ctrl}) then {
    GVAR(CtrlHeld) = false;
};

false
