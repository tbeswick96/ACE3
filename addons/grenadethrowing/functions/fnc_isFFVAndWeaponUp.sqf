/*
 * Author: Dslyecxi, Jonpas
 * Checks if in firing from vehicles seat and has a weapon up.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Is FFV and has weapon up <BOOL>
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_isFFVAndWeaponUp
 *
 * Public: No
 */
#include "script_component.hpp"

private _return = false;

if (vehicle player == player) exitWith {true};

private _assignedRole = assignedVehicleRole player;
if ((_assignedRole select 0 == "cargo") && {count _assignedRole > 1}) then {
    _return = [true, false] select (weaponLowered player); // I think we're FFV!
};

_return
