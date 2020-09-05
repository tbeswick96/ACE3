#include "script_component.hpp"
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

(_unit getVariable [QGVAR(comaTimeLeft), -1]) <= 0
