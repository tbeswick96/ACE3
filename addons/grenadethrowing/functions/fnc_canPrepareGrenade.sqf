/*
 * Author: Jonpas
 * Checks if a grenade can be prepared.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Can Prepare Grenade <BOOL>
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_canPrepareGrenade
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(Enabled) || {call EFUNC(common,isFeatureCameraActive)}) exitWith {false};

params ["_unit"];

[_unit, objNull, ["isNotInside", "isNotSitting", "isNotOnLadder"]] call EFUNC(common,canInteractWith) &&
{[_unit] call CBA_fnc_canUseWeapon}
