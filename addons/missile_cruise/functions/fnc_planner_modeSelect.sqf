#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Selects TOO or PP mode for cruise planner.
 * Disables/enables controls and updates global mode variable.
 *
 * Arguments:
 * 0: Mode IDC <NUMBER> - CRUISE_PLANNER_IDC_MODE_TOO or CRUISE_PLANNER_IDC_MODE_PP
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_mode"];

private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];
if (isNull _display) exitWith {};

private _isToo = _mode == CRUISE_PLANNER_IDC_MODE_TOO;

// Enable/disable controls (use display-explicit form for robustness)
{
    (_display displayCtrl _x) ctrlEnable (!_isToo);
} forEach CONTROLS_DISABLED_IN_TOO;

// Set focus on the selected mode button
ctrlSetFocus (_display displayCtrl _mode);

if (_isToo) then {
    // Switching to TOO: save current PP target first
    if (GVAR(plannerMode) isEqualTo "pp") then {
        call FUNC(planner_saveTarget);
    };
    GVAR(plannerMode) = "too";
} else {
    GVAR(plannerMode) = "pp";
};

// Load settings for the new mode (handles label, fields, waypoint list)
call FUNC(planner_loadTarget);

TRACE_1("planner_modeSelect",GVAR(plannerMode));
