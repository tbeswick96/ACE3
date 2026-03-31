#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Adds a waypoint from the current TGP camera target position.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _vehicle = vehicle ACE_PLAYER;
if (_vehicle == ACE_PLAYER) exitWith {};

private _target = getPilotCameraTarget _vehicle;
_target params ["_tracking", "_position", "_object"];

if (_position isEqualTo [0, 0, 0]) exitWith {
    ["No TGP target"] call EFUNC(common,displayTextStructured);
};

private _posASL = AGLToASL _position;
private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
_waypoints pushBack _posASL;
_vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];

call FUNC(planner_updateList);

private _mapGrid = [_position] call EFUNC(common,getMapGridFromPos);
_mapGrid params ["_easting", "_northing"];
[format ["WP %1 added: %2 %3", count _waypoints, _easting, _northing]] call EFUNC(common,displayTextStructured);
