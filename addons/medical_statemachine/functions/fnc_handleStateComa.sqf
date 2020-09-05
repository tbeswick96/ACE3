#include "script_component.hpp"
/*
 * Author: Tim Beswick
 * Handles the coma state
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

// If the unit died the loop is finished
if (!alive _unit) exitWith {};
if (!local _unit) exitWith {};

[_unit] call EFUNC(medical_vitals,handleUnitVitals);

private _timeDiff = CBA_missionTime - (_unit getVariable [QGVAR(comaTimeLastUpdate), 0]);
if (_timeDiff >= 1) then {
    _timeDiff = _timeDiff min 10;
    _unit setVariable [QGVAR(comaTimeLastUpdate), CBA_missionTime];
    private _timeLeft = _unit getVariable [QGVAR(comaTimeLeft), -1];
    TRACE_2("coma life tick",_unit,_timeDiff);
    _timeLeft = _timeLeft - _timeDiff; // negative values are fine
    _unit setVariable [QGVAR(comaTimeLeft), _timeLeft];
};

