/*
 * Author: Dslyecxi, Jonpas
 * Exits throw mode.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Reason <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit, "reason"] call ace_grenadethrowing_fnc_exitThrowMode
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(GrenadeInHand)) exitWith {};

params ["_unit", "_reason"];
TRACE_1("Exit Throw Mode",_reason);

if (!(simulationEnabled GVAR(ActiveGrenadeItem))) then {
    deleteVehicle GVAR(ActiveGrenadeItem);
};

GVAR(ToggleThrowMode) = false;
GVAR(GrenadeInHand) = false;
GVAR(CookingGrenade) = false;
GVAR(DropCookedCounter) = 0;

// Remove controls hint (check if ever enabled is inside the function)
call EFUNC(interaction,hideMouseHint);

// Remove throw action
[_unit, "DefaultAction", _unit getVariable [QGVAR(ThrowAction), -1]] call EFUNC(common,removeActionEventHandler);

// Remove throw arc draw
if (!isNil QGVAR(Draw3DHandle)) then {
    removeMissionEventHandler ["Draw3D", GVAR(Draw3DHandle)];
    GVAR(Draw3DHandle) = nil;
};
