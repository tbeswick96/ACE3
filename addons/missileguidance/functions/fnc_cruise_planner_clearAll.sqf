#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Clears all cruise planner waypoints.
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
_vehicle setVariable [QGVAR(cruiseWaypoints), [], true];
call FUNC(cruise_planner_updateList);
