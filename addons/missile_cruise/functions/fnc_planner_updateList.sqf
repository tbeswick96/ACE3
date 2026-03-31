#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Refreshes the waypoint listbox display with target, approach WP, and user waypoints.
 * Waypoints are numbered as countdown — highest number is first flown (furthest from target),
 * WP 1 is closest to target (last visited before approach).
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
private _info = _display displayCtrl CRUISE_PLANNER_IDC_INFO;

lbClear _list;

private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";

// Read target from input fields for live display
private _eastingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING);
private _northingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING);
private _headingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING);

private _entryCount = 0;
private _totalDistance = 0;
private _previousPosition = [];
private _waypointCount = count _waypoints;

// TARGET entry (always shown if set)
if (_eastingStr isNotEqualTo "" && {_northingStr isNotEqualTo ""}) then {
    private _listIndex = _list lbAdd format ["TARGET: %1 %2", _eastingStr, _northingStr];
    _list lbSetColor [_listIndex, [1, 0.3, 0.3, 1]];
    _list lbSetValue [_listIndex, -1];
    _entryCount = _entryCount + 1;

    // Compute approach WP if heading is set
    if (_headingStr isNotEqualTo "") then {
        private _heading = parseNumber _headingStr;
        private _gridString = _eastingStr + _northingStr;
        private _targetPosition2D = [_gridString] call EFUNC(common,getMapPosFromGrid);
        private _reverseDirection = [APPROACH_WAYPOINT_DIST, _heading + 180, 0] call CBA_fnc_polar2vect;
        private _approachPosition = _targetPosition2D vectorAdd _reverseDirection;
        private _approachGrid = [_approachPosition] call EFUNC(common,getMapGridFromPos);
        _approachGrid params ["_approachEasting", "_approachNorthing"];

        private _listIndex = _list lbAdd format ["APPROACH WP: %1 %2", _approachEasting, _approachNorthing];
        _list lbSetColor [_listIndex, [0.3, 1, 0.3, 1]];
        _list lbSetValue [_listIndex, -1];
        _entryCount = _entryCount + 1;
    };
};

// User waypoints in array order (matches map display)
// Numbered as countdown: highest number = first flown (furthest from target)
for "_i" from 0 to (_waypointCount - 1) do {
    private _waypoint = _waypoints#_i;
    if (count _waypoint < 3) then {continue};
    private _positionAGL = ASLToAGL _waypoint;
    private _mapGrid = [_positionAGL] call EFUNC(common,getMapGridFromPos);
    _mapGrid params ["_easting", "_northing"];

    private _distanceString = "";
    if (_previousPosition isNotEqualTo []) then {
        private _legDistance = [_previousPosition#0, _previousPosition#1, 0] vectorDistance [_waypoint#0, _waypoint#1, 0];
        _totalDistance = _totalDistance + _legDistance;
        _distanceString = format [" (%1m)", round _legDistance];
    };

    private _waypointNumber = _waypointCount - _i;
    private _text = format ["WP %1: %2 %3%4", _waypointNumber, _easting, _northing, _distanceString];
    private _listIndex = _list lbAdd _text;
    _list lbSetColor [_listIndex, [1, 0.8, 0, 1]];
    _list lbSetValue [_listIndex, _i];
    _entryCount = _entryCount + 1;

    _previousPosition = _waypoint;
};

private _countString = format ["%1 entr%2", _entryCount, ["ies", "y"] select (_entryCount == 1)];
if (_totalDistance > 0) then {
    _countString = format ["%1 | Total: %2m", _countString, round _totalDistance];
};
_info ctrlSetText _countString;
