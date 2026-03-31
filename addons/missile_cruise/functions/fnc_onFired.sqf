#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Initializes cruise missile state on fired event.
 * Reads target data from cruiseTargetSettings vehicle variable (independent of GPS).
 * Overrides seeker state params so GPS seeker returns our target.
 *
 * Arguments:
 * Guidance Arg Array <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_missile_cruise_fnc_onFired
 *
 * Public: No
 */

params ["_firedEH", "", "", "", "_stateParams", "", ""];
_stateParams params ["", "_seekerStateParams", "_attackProfileStateParams"];
_firedEH params ["_shooter","","","","_ammo","","_projectile"];

private _vehicle = vehicle _shooter;

// Read target data from our own vehicle variable (NOT from gps_getAttackData)
private _settings = _vehicle getVariable [QGVAR(cruiseTargetSettings), []];
private _targetPosition = [0, 0, 0];
private _impactAngle = -1;
private _attackDirection = -1;

if (count _settings >= 3) then {
    _targetPosition = +(_settings select 0);
    _impactAngle = _settings select 1;
    _attackDirection = _settings select 2;
};

// Build GPS-compatible data array: [position, impactAngle, attackDirection]
private _gpsData = [+_targetPosition, _impactAngle, _attackDirection];

// Override seeker state params so GPS seeker frame function returns our target
// (gps_seekerOnFired runs first and writes gps_getAttackData to _seekerStateParams[0],
//  we overwrite it here with our own data)
_seekerStateParams set [0, [+_targetPosition, _impactAngle, _attackDirection]];

// Get cruise altitude from vehicle variable (set by cruise planner dialog)
private _cruiseAltitude = _vehicle getVariable [QGVAR(cruiseAltitude), 100];

// Compute approach waypoint if attack direction is set
private _approachWaypoint = [0, 0, 0];
if (_attackDirection >= 0) then {
    private _reverseDirection = [APPROACH_WAYPOINT_DIST, _attackDirection + 180, 0] call CBA_fnc_polar2vect;
    _approachWaypoint = _targetPosition vectorAdd _reverseDirection;
    _approachWaypoint set [2, ((getTerrainHeightASL _approachWaypoint) max 0) + _cruiseAltitude];
};

private _launchPosition = getPosASL _projectile;

// Read cruise planner waypoints from vehicle variable (deep copy + filter invalid)
// Reverse so missile flies them in display order (top-to-bottom = countdown to target)
private _waypoints = +(_vehicle getVariable [QGVAR(cruiseWaypoints), []]);
_waypoints = _waypoints select {count _x >= 3};
reverse _waypoints;

// Append approach WP as last waypoint so missile flies through it before popup
if (_approachWaypoint isNotEqualTo [0, 0, 0]) then {
    _waypoints pushBack +_approachWaypoint;
};

// Initialize state params:
// [0] stage, [1] gpsData, [2] cruiseAltitude, [3] approachWaypoint, [4] launchPosition, [5] lastDesiredAltitude, [6] waypoints, [7] currentWaypointIndex
_attackProfileStateParams set [0, STAGE_LAUNCH];
_attackProfileStateParams set [1, _gpsData];
_attackProfileStateParams set [2, _cruiseAltitude];
_attackProfileStateParams set [3, _approachWaypoint];
_attackProfileStateParams set [4, _launchPosition];
_attackProfileStateParams set [5, 0];
_attackProfileStateParams set [6, _waypoints];
_attackProfileStateParams set [7, 0];

TRACE_3("cruise_missile_onFired",_targetPosition,_impactAngle,_attackDirection);
