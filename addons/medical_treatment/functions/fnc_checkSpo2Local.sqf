#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Local callback for checking the Spo2 of a patient.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "Head"] call ace_medical_treatment_fnc_checkSpo2Local
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

private _spo2 = GET_SPO2(_patient);
TRACE_1("",_spo2);

[_patient, "quick_view", LSTRING(CheckSpo2_Log), [_medic call EFUNC(common,getName), _spo2]] call FUNC(addToLog);
[QEGVAR(common,displayTextStructured), [[LSTRING(CheckSpo2_Output), _spo2], 1.5, _medic], _medic] call CBA_fnc_targetEvent;
