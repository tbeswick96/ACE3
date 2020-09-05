#include "script_component.hpp"
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

private _comatose = IN_COMA(_patient);
private _comaTime = _unit setVariable [QEGVAR(medical_statemachine,comaTimeLeft), -1];

// dead: remain fully dilated
private _dilationOutput = LSTRING(Check_Pupils_Output_Fully);
private _logOutput = LSTRING(Check_Pupils_Dilated);

if (alive _patient) then {
    if (_comatose) then {
        if (_comaTime > 1) then {
            if (_comaTime > 6) then {
                if (_comaTime > 12) then {
                    // > 12: constrict normally
                    _dilationOutput = LSTRING(Check_Pupils_Output_Constricted);
                    _logOutput = LSTRING(Check_Pupils_Constricted);
                } else {
                    // > 6: constrict slowly
                    _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Mostly);
                    _logOutput = LSTRING(Check_Pupils_Constrict_Mostly);
                };
            } else {
                // < 6: constrict barely
                _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Barely);
                _logOutput = LSTRING(Check_Pupils_Constrict_Barely);
            };
        };
        // < 1: remain fully dilated
    } else {
        // alive not comatose: constrict normally
        _dilationOutput = LSTRING(Check_Pupils_Output_Constricted);
        _logOutput = LSTRING(Check_Pupils_Constricted);
    };
};

[_patient, "quick_view", LSTRING(Check_Pupils_Log), [_medic call EFUNC(common,getName), _logOutput]] call FUNC(addToLog);

[QEGVAR(common,displayTextStructured), [[_dilationOutput], 1.5, _medic], _medic] call CBA_fnc_targetEvent;
