/*
 * Author: Dslyecxi, Jonpas
 * Key down event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Suppress Key <BOOL>
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_onKeyDown
 *
 * Public: No
 */
#include "script_component.hpp"

params ["", "_key", "_shift", "_ctrl", "_alt"];

if (call EFUNC(common,isFeatureCameraActive)) exitWith {false};

private _suppress = false;

if (_ctrl) then {
    GVAR(CtrlLastPressed) = time;

    if (!GVAR(CtrlHeld)) then {
        [{
            GVAR(ThrowType) = "normal";
            time - GVAR(CtrlLastPressed) > 0.25; // Delay to prevent flickering between both positions
        }, {
            GVAR(TestPercArm) = 1;
            GVAR(CtrlHeld) = false
        }, []] call EFUNC(common,waitUntilAndExecute)
    };
    GVAR(CtrlHeld) = true;
};

#ifdef DEBUG_MODE_FULL
if (_key in (actionKeys "CycleThrownItems")) then {
    [{
        private _currentThrowable = (currentThrowable player) select 0;
        TRACE_1("Select Throwable",_currentThrowable,GVAR(CurrentThrowSpeed));
    }, [] , 0.01] call EFUNC(common,waitAndExecute);
};
#endif

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
    ["Pressed a key that cycles us out of grenades"] call FUNC(exitThrowMode);
    false
};

if (cameraView != "INTERNAL" && {GVAR(GrenadeInHand)}) exitWith {
    ["Went into sights"] call FUNC(exitThrowMode);
    false
};

if ((_key in (actionKeys "CycleThrownItems")) && {!GVAR(ToggleThrowMode)}) then {
    _suppress = true;

    if (GVAR(CookingGrenade)) exitWith {}; // Just don't do anything if we're cooking

    if (!(call FUNC(isFFVAndWeaponUp))) exitWith {
        ["Not FFV with weapon up"] call FUNC(exitThrowMode);
        true // Capturing the key to prevent cycling
    };

    if (((currentThrowable player) select 0) == "") exitWith {
        ["No grenade actively selected (or available?)"] call FUNC(exitThrowMode);
        GVAR(LastTimeSwitchKeyPressed) = time - 4;
        _suppress = false;
        _suppress
    };

    if (time < GVAR(LastTimeSwitchKeyPressed) + 0.5) exitWith {true};

    if (time - GVAR(LastThrownTime) < GVAR(TimeBetweenThrows)) exitWith {
        ["Time between throws hasn't happened"] call FUNC(exitThrowMode);
        true
    };

    GVAR(ToggleThrowMode) = !GVAR(ToggleThrowMode);

    // Throw mode is on
    if (GVAR(ToggleThrowMode)) then {
        GVAR(ThrowType) = "normal";
        GVAR(AmmoLastMag) = player ammo (currentWeapon player);
        player setAmmo [currentWeapon player, 0];
        inGameUISetEventHandler ["PrevAction", "true"];
        inGameUISetEventHandler ["NextAction", "true"];
        inGameUISetEventHandler ["Action", "true"];

        if (!GVAR(GrenadeInHand)) then {
            GVAR(ThrowGrenade) = false;
            call FUNC(throw);
        };
    } else {
        ["Exit 5"] call FUNC(exitThrowMode);
        player setAmmo [currentWeapon player, GVAR(AmmoLastMag)];
    };

    GVAR(LastTimeSwitchKeyPressed) = time;
    _suppress
};

_suppress
