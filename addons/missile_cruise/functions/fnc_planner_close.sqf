#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on unload of cruise planner dialog.
 * Saves current UI state to active target entry and cleans up map click handlers.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];

if (!isNull _display) then {
    // Save current UI fields to active target
    call FUNC(planner_saveTarget);

    // Remove any pending map click handlers
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlRemoveAllEventHandlers "MouseButtonClick";
};

// Draw EH on map control is auto-removed when dialog closes
