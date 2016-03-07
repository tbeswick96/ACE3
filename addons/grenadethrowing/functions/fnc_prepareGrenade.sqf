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
 * [unit] call ace_grenadethrowing_fnc_prepareGrenade
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

private _currentThrowable = currentThrowable _unit;

// Try selecting next grenade if none currently selected
if (_currentThrowable select 0 == "" && {!([_unit] call EFUNC(weaponselect,selectNextGrenade))}) exitWith {
    [_unit, "No valid throwables"] call FUNC(exitThrowMode);
    false
};

private _dropType = getText (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "ammo");

if (_dropType == "") exitWith {
    [_unit, "No valid throwables (check 2)"] call FUNC(exitThrowMode);
    false
};


// Select next grenade if one already in hand
if (GVAR(GrenadeInHand)) then {
    [_unit] call EFUNC(weaponselect,selectNextGrenade);
} else {
    GVAR(ToggleThrowMode) = !GVAR(ToggleThrowMode);

    // Throw mode is enabled, prepare
    if (GVAR(ToggleThrowMode)) then {
        GVAR(ThrowType) = "normal";

        // Since we have something to throw, let's create it. By activating GrenadeInHand, the PFH creates a grenade
        GVAR(ActiveGrenadeType) = _dropType;
        GVAR(CookingGrenade) = false; // Can't be cooking, just pulled it.
        GVAR(CtrlHeld) = false;
        GVAR(LastGrenadeTypeChecked) = "";
        GVAR(GrenadeInHand) = true;

        // Add controls hint if enabled
        if (GVAR(ShowMouseControls)) then {
            [localize LSTRING(Throw), localize LSTRING(Cancel), localize LSTRING(ChangeModeOrCook)] call EFUNC(interaction,showMouseHint);
        };

        // Add throw action
        _unit setVariable [QGVAR(ThrowAction), [
            _unit, "DefaultAction",
            {[_this select 0] call FUNC(canThrow)},
            {[_this select 0] call FUNC(confirmThrow)}
        ] call EFUNC(common,addActionEventHandler)];

        // Visualize the grenade
        [FUNC(pfh), 0, [_unit]] call CBA_fnc_addPerFrameHandler; // Removal inside PFH

        // Draw throw arc if enabled
        if (GVAR(ShowThrowArc)) then {
            GVAR(Draw3DHandle) = addMissionEventHandler ["Draw3D", {call FUNC(draw3d);}];
        };
    };
};

true
