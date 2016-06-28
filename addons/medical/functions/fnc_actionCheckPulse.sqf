/*
* Author: Glowbal
* Action for checking the pulse or heart rate of the patient
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

params ["_caller","_target", "_selectionName"];
if (local _target) then {
    [QGVAR(actionCheckPulseLocal), [_caller, _target, _selectionName]] call CBA_fnc_localEvent;
} else {
    [QGVAR(actionCheckPulseLocal), [_caller, _target, _selectionName], _target] call CBA_fnc_targetEvent;
};
