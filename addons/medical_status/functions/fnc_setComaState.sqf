#include "script_component.hpp"
/*
 * Author: Tim Beswick
 * Marks a unit as in a coma.
 * Will put the unit in an unconscious state if not already.
 * For Internal Use: Called from the state machine entered/leftState funcs.
 *
 * Arguments:
 * 0: The unit that will be put in coma state <OBJECT>
 * 1: Set Coma <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, true] call ace_medical_status_fnc_setComaState
 *
 * Public: No
 */

params ["_unit", "_active"];
TRACE_2("setComaState",_unit,_active);

// No change to make
if (_active isEqualTo IN_COMA(_unit)) exitWith { TRACE_2("no change",_active,IN_COMA(_unit)); };

_unit setVariable [VAR_COMA, _active, true];

["ace_coma", [_unit, _active]] call CBA_fnc_localEvent;
