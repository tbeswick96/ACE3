#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Enables map click mode on planner map to set target position.
 * Click handler is removed after one click.
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
if (isNull _display) exitWith {};

private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;

// Remove any existing click handler (target or waypoint mode)
_map ctrlRemoveAllEventHandlers "MouseButtonClick";

["Click map to set target..."] call EFUNC(common,displayTextStructured);

_map ctrlAddEventHandler ["MouseButtonClick", {
    params ["_map", "_button", "_xPos", "_yPos"];
    if (_button != 0) exitWith {};

    private _worldPos = _map ctrlMapScreenToWorld [_xPos, _yPos];

    // Convert to grid
    private _mapGrid = [_worldPos] call EFUNC(common,getMapGridFromPos);
    _mapGrid params ["_easting", "_northing"];

    // Populate fields — leave height empty so close handler uses terrain height from grid
    private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];
    if (!isNull _display) then {
        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText _easting;
        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText _northing;
        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT) ctrlSetText "";
    };

    call FUNC(cruise_planner_updateList);

    // Remove this handler after one click
    _map ctrlRemoveAllEventHandlers "MouseButtonClick";

    [format ["Target set: %1 %2", _easting, _northing]] call EFUNC(common,displayTextStructured);
}];
