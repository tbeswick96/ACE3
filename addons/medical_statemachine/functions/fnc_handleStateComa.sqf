#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Coma state per-tick handler. With endpoint-based timer (comaEndTime),
 * no per-tick decrement is needed; condition check reads the endpoint directly.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_statemachine_fnc_handleStateComa
 *
 * Public: No
 */

params ["_unit"];

if (!alive _unit || {!local _unit}) exitWith {};

[_unit] call EFUNC(medical_vitals,handleUnitVitals);
