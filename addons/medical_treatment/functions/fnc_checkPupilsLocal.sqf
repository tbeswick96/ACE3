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

private _comatose = false;
private _comaTime = _unit setVariable [QEGVAR(medical_statemachine,comaTimeLeft), nil];
if (alive _patient && {IN_COMA(_patient)}) then {
    _comatose = true;
};

/*
    time > 10: constrict normally
    time > 5: constrict mostly
    time < 5: constrict barely
    time < 1: remain fully dilated
*/

// < 1 or dead: remain fully dilated
private _dilationOutput = LSTRING(Check_Pupils_Output_Fully);
private _logOutput = LSTRING(Check_Pupils_Dilated);

if (_comatose && _comaTime > 1) then {
    if (_comaTime > 5) then {
        if (_comaTime > 10) then { // > 10: constrict normally
            _dilationOutput = LSTRING(Check_Pupils_Output_Constricted);
            _logOutput = LSTRING(Check_Pupils_Constricted);
        } else { // > 5: constrict slowly
            _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Mostly);
            _logOutput = LSTRING(Check_Pupils_Constrict_Mostly);
        };
    } else { // < 5: constrict barely
        _dilationOutput = LSTRING(Check_Pupils_Output_Constrict_Barely);
        _logOutput = LSTRING(Check_Pupils_Constrict_Barely);
    };
};

[_patient, "quick_view", LSTRING(Check_Pupils_Log), [_medic call EFUNC(common,getName), _logOutput]] call FUNC(addToLog);

[QEGVAR(common,displayTextStructured), [[_dilationOutput], 1.5, _medic], _medic] call CBA_fnc_targetEvent;
