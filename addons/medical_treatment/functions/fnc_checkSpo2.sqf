#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Checks the Spo2 of the patient.
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
 * [player, cursorObject, "Head"] call ace_medical_treatment_fnc_checkSpo2
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

[QGVAR(checkSpo2Local), [_medic, _patient, _bodyPart], _patient] call CBA_fnc_targetEvent;
