#include "..\script_component.hpp"
/*
 * Author: Yep
 * Local callback for forcing patient to drink a bag of bloody piss
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_pissBagLocal
 *
 * Public: No
 */

params ["_patient"];

[_patient, 1] call EFUNC(medical,adjustPainLevel);
