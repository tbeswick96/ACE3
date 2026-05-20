#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Dispatches dialog open / close based on ace_unconscious event.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Is unconscious <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _isUncon] call ace_medical_unconview_fnc_handleUnconsciousState
 *
 * Public: No
 */
params ["_unit", "_isUncon"];

if (_unit != ACE_player) exitWith {};
if (!GVAR(enabled)) exitWith {};

if (_isUncon) exitWith {
    [] call FUNC(openDialog);
};

[] call FUNC(closeDialog);
