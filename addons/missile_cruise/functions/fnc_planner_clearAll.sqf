#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Clears all cruise planner waypoints for the active target.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

(GVAR(targetSettings) get GVAR(activeTarget)) set ["waypoints", []];
call FUNC(planner_updateList);
