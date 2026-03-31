#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on load of cruise planner dialog.
 * Stores display reference, populates cruise altitude combo,
 * loads active target entry, and registers map Draw EH.
 *
 * Arguments:
 * Display <DISPLAY> (from onLoad)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

[{
    params ["_display"];
    TRACE_1("cruise_planner_open",_display);
    uiNamespace setVariable [QGVAR(cruisePlannerDisplay), _display];

    // Populate cruise altitude combo (must happen before loadTarget sets selection)
    private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
    _combo lbAdd "50m";
    _combo lbAdd "100m";
    _combo lbAdd "150m";

    // Load active target entry into UI fields
    call FUNC(planner_loadTarget);

    // Refresh list when heading field changes (approach WP depends on heading)
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING) ctrlAddEventHandler ["KeyUp", {
        call FUNC(planner_updateList);
    }];

    // Register Draw EH on map control (drawIcon/drawLine require onDraw context)
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlAddEventHandler ["Draw", {
        call FUNC(planner_drawMap);
    }];
}, _this] call CBA_fnc_execNextFrame;
