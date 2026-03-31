#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Initializes cruise missile state on fired event.
 * Deep-copies the active target entry from the targetSettings hashmap.
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

// Deep-copy active target entry so in-flight missile is isolated from dialog changes
private _entry = +(GVAR(targetSettings) get GVAR(activeTarget));
private _targetPosition = +(_entry get "position");
private _impactAngle = _entry get "impactAngle";
private _attackDirection = _entry get "attackHeading";
private _cruiseAltitude = _entry get "cruiseAltitude";

// Build GPS-compatible data array: [position, impactAngle, attackDirection]
private _gpsData = [+_targetPosition, _impactAngle, _attackDirection];

// Override seeker state params so GPS seeker frame function returns our target
// (gps_seekerOnFired runs first and writes gps_getAttackData to _seekerStateParams[0],
//  we overwrite it here with our own data)
_seekerStateParams set [0, [+_targetPosition, _impactAngle, _attackDirection]];

// Compute approach waypoint if attack direction is set
private _approachWaypoint = [0, 0, 0];
if (_attackDirection >= 0) then {
    private _reverseDirection = [APPROACH_WAYPOINT_DIST, _attackDirection + 180, 0] call CBA_fnc_polar2vect;
    _approachWaypoint = _targetPosition vectorAdd _reverseDirection;
    _approachWaypoint set [2, ((getTerrainHeightASL _approachWaypoint) max 0) + _cruiseAltitude];
};

private _launchPosition = getPosASL _projectile;

// Deep copy waypoints, filter invalid, reverse for flight order
private _waypoints = +(_entry get "waypoints");
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

TRACE_3("onFired",_targetPosition,_impactAngle,_attackDirection);
