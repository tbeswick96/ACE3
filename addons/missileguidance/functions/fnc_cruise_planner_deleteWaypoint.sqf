#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Deletes the currently selected waypoint from the list.
 * Uses lbValue to map listbox selection to waypoint array index.
 * Header entries (TARGET, APPROACH WP) have value -1 and cannot be deleted.
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

private _list = _display displayCtrl CRUISE_PLANNER_IDC_LIST;
private _selectedIndex = lbCurSel _list;

if (_selectedIndex < 0) exitWith {};

private _wpIndex = _list lbValue _selectedIndex;

// Don't allow deleting header entries (TARGET, APPROACH WP)
if (_wpIndex < 0) exitWith {};

private _vehicle = vehicle ACE_PLAYER;
if (_vehicle == ACE_PLAYER) exitWith {};

private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];

if (_wpIndex >= count _waypoints) exitWith {};

_waypoints deleteAt _wpIndex;
_vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];

call FUNC(cruise_planner_updateList);

// Keep selection near deleted index
private _newSel = (_selectedIndex min (lbSize _list - 1)) max 0;
if (lbSize _list > 0) then {
    _list lbSetCurSel _newSel;
};
