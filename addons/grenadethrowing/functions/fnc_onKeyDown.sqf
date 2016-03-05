/*
 * Author: Dslyecxi, Jonpas
 * Key down event.
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
 * [control, 5, false, true, false] call ace_grenadethrowing_fnc_onKeyDown
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(GrenadeInHand) || {call EFUNC(common,isFeatureCameraActive)}) exitWith {false};

params ["", "_key", "_shift", "_ctrl", "_alt"];

// Extend arm drop mode (only on foot)
if (vehicle ACE_player == ACE_player && {_ctrl}) then {
    GVAR(CtrlLastPressed) = time;

    if (!GVAR(CtrlHeld)) then {
        [{
            GVAR(ThrowType) = "normal";
            time - GVAR(CtrlLastPressed) > 0.7; // Delay to prevent flickering between both positions
        }, {
            GVAR(TestPercArm) = 1;
            GVAR(CtrlHeld) = false
        }, []] call EFUNC(common,waitUntilAndExecute)
    };
    GVAR(CtrlHeld) = true;
};

// Reasons for why we'd exit. Probably can find a better way to do this, but this isn't bad.
if (((_key in (actionKeys "ReloadMagazine")) ||
    (_key in (actionKeys "Handgun")) ||
    (_key in (actionKeys "Binoculars")) ||
    (_key in (actionKeys "SwitchWeapon")) ||
    (_key in (actionKeys "Optics")) ||
    (_key in (actionKeys "NextWeapon")) ||
    (_key in (actionKeys "PrevWeapon")) ||
    (_key in (actionKeys "OpticsTemp")) ||
    (_key in (actionKeys "SwitchPrimary")) ||
    (_key in (actionKeys "SwitchHandgun")) ||
    (_key in (actionKeys "SwitchSecondary"))) &&
    GVAR(ToggleThrowMode)
) exitWith {
    [ACE_player, "Pressed a key that cycles us out of grenades"] call FUNC(exitThrowMode);
    false
};

false
