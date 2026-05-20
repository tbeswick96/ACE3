#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Switches to the Health tab. Hides spectator content, shows health rows,
 * tears down the spectator PFH + camera so they aren't running behind the health view.
 * Triggers an immediate vitalsUpdate so values populate without delay.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_medical_unconview_fnc_openHealthTab
 *
 * Public: No
 */

private _display = findDisplay IDD_UNCON;
if (isNull _display) exitWith {};

call FUNC(hidePreviousTabs);

if (GVAR(activeSpectatorPFH) != -1) then {
    [GVAR(activeSpectatorPFH)] call CBA_fnc_removePerFrameHandler;
    GVAR(activeSpectatorPFH) = -1;
};
call FUNC(spectatorCleanup);

GVAR(currentTab) = "health";

{
    (_display displayCtrl _x) ctrlShow true;
} forEach [IDC_HEALTH_HR, IDC_HEALTH_BP, IDC_HEALTH_RESP, IDC_HEALTH_SPO2, IDC_HEALTH_BLOODVOL, IDC_HEALTH_PAIN, IDC_HEALTH_STATE_TIMER, IDC_HEALTH_TABFOCUS];

(_display displayCtrl IDC_HEALTH_TABFOCUS) ctrlEnable true;

[[], -1] call FUNC(vitalsUpdate);
