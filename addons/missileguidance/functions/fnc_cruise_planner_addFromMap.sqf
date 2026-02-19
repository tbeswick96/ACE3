#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Enables map click mode to place a waypoint on the planner map.
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

["Click map to place waypoint..."] call EFUNC(common,displayTextStructured);

_map ctrlAddEventHandler ["MouseButtonClick", {
    params ["_map", "_button", "_xPos", "_yPos"];
    if (_button != 0) exitWith {};

    private _worldPos = _map ctrlMapScreenToWorld [_xPos, _yPos];
    private _posASL = [_worldPos select 0, _worldPos select 1, getTerrainHeightASL _worldPos];

    private _vehicle = vehicle ACE_PLAYER;
    private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
    _waypoints pushBack _posASL;
    _vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];

    call FUNC(cruise_planner_updateList);

    // Remove this handler after one click
    _map ctrlRemoveAllEventHandlers "MouseButtonClick";

    private _mapGrid = [ASLToAGL _posASL] call EFUNC(common,getMapGridFromPos);
    _mapGrid params ["_easting", "_northing"];
    [format ["WP %1 added: %2 %3", count _waypoints, _easting, _northing]] call EFUNC(common,displayTextStructured);
}];
