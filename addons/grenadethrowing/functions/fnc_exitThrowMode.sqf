/*
 * Author: Dslyecxi, Jonpas
 * Exits throw mode.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_exitThrowMode
 *
 * Public: No
 */
#include "script_component.hpp"

if (GVAR(ExitInProgress)) exitWith {}; // Already doing an exit

params ["_unit", "_reason"];
TRACE_1("Exit Throw Mode",_reason);

if (!(simulationEnabled GVAR(ActiveGrenadeItem))) then {
    deleteVehicle GVAR(ActiveGrenadeItem);
};

GVAR(ExitInProgress) = true;

GVAR(CancelThrow) = true;
GVAR(ToggleThrowMode) = false;
GVAR(ThrowGrenade) = true; // To clear up the waiting script
GVAR(GrenadeInHand) = false;

_unit setAmmo [currentWeapon _unit, GVAR(AmmoLastMag)];

[{
    if (dialog) exitWith {}; // Prevent running if we went into a dialog

    GVAR(CancelThrow) = false;
    GVAR(ThrowGrenade) = false;
    inGameUISetEventHandler ["PrevAction", "false"];
    inGameUISetEventHandler ["NextAction", "false"];
    inGameUISetEventHandler ["Action", "false"];
    GVAR(ExitInProgress) = false;
}, [], 0.1] call  EFUNC(common,waitAndExecute);

[{
    GVAR(CookingGrenade) = false;
    GVAR(DropCookedCounter) = 0;
}, [], 0.95] call  EFUNC(common,waitAndExecute);
