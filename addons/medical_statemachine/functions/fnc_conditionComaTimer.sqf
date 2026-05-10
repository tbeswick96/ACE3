#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Checks if the coma timer ran out.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_statemachine_fnc_conditionComaTimer
 *
 * Public: No
 */

params ["_unit"];

private _endTime = _unit getVariable [QGVAR(comaEndTime), -1];
_endTime > -1 && {_endTime <= CBA_missionTime}
