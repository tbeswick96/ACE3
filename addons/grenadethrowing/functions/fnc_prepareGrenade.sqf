/*
 * Author: Dslyecxi, Jonpas
 * Prepares grenade.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_prepareGrenade
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

if (GVAR(ToggleThrowMode) || {GVAR(CookingGrenade)}) exitWith {false};

if ((currentThrowable _unit) select 0 == "") exitWith {
    [_unit, "No grenade actively selected (or available?)"] call FUNC(exitThrowMode);
    GVAR(LastTimeSwitchKeyPressed) = time - 4;
    false
};

if (time < GVAR(LastTimeSwitchKeyPressed) + 0.5) exitWith {true};

if (time - GVAR(LastThrownTime) < GVAR(TimeBetweenThrows)) exitWith {
    [_unit, "Time between throws hasn't happened"] call FUNC(exitThrowMode);
    false
};

GVAR(ToggleThrowMode) = !GVAR(ToggleThrowMode);

// Throw mode is on
if (GVAR(ToggleThrowMode)) then {
    GVAR(ThrowType) = "normal";
    GVAR(AmmoLastMag) = _unit ammo (currentWeapon _unit);
    _unit setAmmo [currentWeapon _unit, 0];
    inGameUISetEventHandler ["PrevAction", "true"];
    inGameUISetEventHandler ["NextAction", "true"];
    inGameUISetEventHandler ["Action", "true"];

    if (!GVAR(GrenadeInHand)) then {
        GVAR(ThrowGrenade) = false;
        [_unit] call FUNC(throw);
    };
} else {
    [_unit, "Exit 5"] call FUNC(exitThrowMode);
    _unit setAmmo [currentWeapon _unit, GVAR(AmmoLastMag)];
};

GVAR(LastTimeSwitchKeyPressed) = time;

true
