#include "script_component.hpp"
/*
 * Author: Tim Beswick
 * Handles a unit entering coma (calls for a status update).
 * Sets required variables for countdown timer until death.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_statemachine_fnc_enteredStateComa
 *
 * Public: No
 */

params ["_unit"];

// 10% possible variance in coma time
private _time = GVAR(comaTime);
_time = _time + _time * random [-0.1, 0, 0.1];

_unit setVariable [QGVAR(comaTimeLeft), _time];
_unit setVariable [QGVAR(comaTimeLastUpdate), CBA_missionTime];

TRACE_3("enteredStateComa",_unit,_time,CBA_missionTime);

// Update the unit status to reflect coma
[_unit, true] call EFUNC(medical_status,setComaState);
