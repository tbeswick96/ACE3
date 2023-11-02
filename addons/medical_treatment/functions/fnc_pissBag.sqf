#include "..\script_component.hpp"
/*
 * Author: Yep
 * Forces patient to drink a bag of bloody piss
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Body Part <STRING>
 * 3: Treatment <STRING>
 * 4: Item User (not used) <OBJECT>
 * 5: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorObject, "Head", "BagOfPiss", objNull, "ACE_bagOfPiss"] call ace_medical_treatment_fnc_pissBag
 *
 * Public: No
 */

params ["_medic", "_patient", "_bodyPart", "_classname", "", "_usedItem"];

[_patient, _usedItem] call FUNC(addToTriageCard);
[_patient, "activity", "%1 forced %2 to drink a bag of piss lmao", [[_medic, false, true] call EFUNC(common,getName), [_patient, false, true] call EFUNC(common,getName)]] call FUNC(addToLog);

[QGVAR(pissBagLocal), [_patient], _patient] call CBA_fnc_targetEvent;
