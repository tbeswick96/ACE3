#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Local callback for checking the pupil dilation of a patient.
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
 * [player, cursorObject, "Head"] call ace_medical_treatment_fnc_checkPupilsLocal
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart"];

// Default: dead / late coma — fully dilated
private _dilationOutput = LSTRING(Check_Pupils_Output_Fully);
private _logOutput = LSTRING(Check_Pupils_Dilated);

if (alive _patient) then {
    if (IN_COMA(_patient)) then {
        private _comaEndTime = _patient getVariable [QEGVAR(medical_statemachine,comaEndTime), -1];
        private _remaining = if (_comaEndTime < 0) then {-1} else {_comaEndTime - CBA_missionTime};
        private _mostlyMin = EGVAR(medical_statemachine,comaTime) * 0.5; // remaining above → mostly
        private _barelyMin = EGVAR(medical_statemachine,comaTime) * 0.1; // remaining above → barely

        if (_remaining > _mostlyMin) then {
            _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Mostly);
            _logOutput = LSTRING(Check_Pupils_Constrict_Mostly);
        } else {
            if (_remaining > _barelyMin) then {
                _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Barely);
                _logOutput = LSTRING(Check_Pupils_Constrict_Barely);
            };
        };
    } else {
        _dilationOutput = LSTRING(Check_Pupils_Output_Constricted);
        _logOutput = LSTRING(Check_Pupils_Constricted);
    };
};

[_patient, "quick_view", LSTRING(Check_Pupils_Log), [_medic call EFUNC(common,getName), _logOutput]] call FUNC(addToLog);

[QEGVAR(common,displayTextStructured), [[_dilationOutput], 1.5, _medic], _medic] call CBA_fnc_targetEvent;
