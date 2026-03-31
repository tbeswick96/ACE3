#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Moves the selected waypoint up or down in the list.
 * Uses lbValue to map listbox selection to waypoint array index.
 *
 * Arguments:
 * 0: Direction (-1 = up, +1 = down) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_direction"];

private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];
if (isNull _display) exitWith {};

private _list = _display displayCtrl CRUISE_PLANNER_IDC_LIST;
private _selectedIndex = lbCurSel _list;

if (_selectedIndex < 0) exitWith {};

private _wpIndex = _list lbValue _selectedIndex;

// Don't allow moving header entries
if (_wpIndex < 0) exitWith {};

private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";

private _newWpIndex = _wpIndex + _direction;
if (_newWpIndex < 0 || {_newWpIndex >= count _waypoints}) exitWith {};

// Swap
private _temp = _waypoints select _wpIndex;
_waypoints set [_wpIndex, _waypoints select _newWpIndex];
_waypoints set [_newWpIndex, _temp];

call FUNC(planner_updateList);

// Re-select the moved entry by finding its new listbox index
for "_i" from 0 to (lbSize _list - 1) do {
    if (_list lbValue _i == _newWpIndex) exitWith {
        _list lbSetCurSel _i;
    };
};
