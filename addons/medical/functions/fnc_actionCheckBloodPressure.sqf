/*
* Author: Glowbal
* Action for checking the blood pressure of the patient
*
* Arguments:
* 0: The medic <OBJECT>
* 1: The patient <OBJECT>
*
* Return Value:
* None
*
* Public: No
*/

#include "script_component.hpp"

params ["_caller", "_target", "_selectionName"];
if (local _target) then {
    [QGVAR(actionCheckBloodPressureLocal), [_caller, _target, _selectionName]] call CBA_fnc_localEvent;
} else {
    [QGVAR(actionCheckBloodPressureLocal), [_caller, _target, _selectionName], _target] call CBA_fnc_targetEvent;
};
