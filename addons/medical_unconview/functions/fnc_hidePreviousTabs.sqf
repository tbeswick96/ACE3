#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Hides all tab content controls (health rows + spectator widgets). Called before
 * switching tabs to ensure clean state.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_medical_unconview_fnc_hidePreviousTabs
 *
 * Public: No
 */

private _display = findDisplay IDD_UNCON;
if (isNull _display) exitWith {};

private _ids = [
    IDC_SPEC_TOO_FAR, IDC_SPEC_INFO, IDC_SPEC_PIP, IDC_SPEC_NO_SIGNAL,
    IDC_SPEC_NVG_0, IDC_SPEC_NVG_1, IDC_SPEC_NVG_2,
    IDC_HEALTH_HR, IDC_HEALTH_BP, IDC_HEALTH_RESP, IDC_HEALTH_SPO2,
    IDC_HEALTH_BLOODVOL, IDC_HEALTH_PAIN,
    IDC_HEALTH_STATE_TIMER, IDC_HEALTH_TABFOCUS
];

{
    (_display displayCtrl _x) ctrlShow false;
} forEach _ids;

(_display displayCtrl IDC_HEALTH_TABFOCUS) ctrlEnable false;
