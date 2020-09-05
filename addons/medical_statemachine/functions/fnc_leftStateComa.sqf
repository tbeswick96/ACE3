#include "script_component.hpp"
/*
 * Author: Tim Beswick
 * Handles a unit leaving coma (calls for a status update).
 * Clears countdown timer variables.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_statemachine_fnc_leftStateComa
 *
 * Public: No
 */

params ["_unit"];
TRACE_1("leftStateComa",_unit);

_unit setVariable [QGVAR(comaTimeLeft), nil];
_unit setVariable [QGVAR(comaTimeLastUpdate), nil];

[_unit, false] call EFUNC(medical_status,setComaState);
