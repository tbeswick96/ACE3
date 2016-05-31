/*
 * Author: commy2
 * Get the turret index of a vehicles gunner.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Vehicle Gunner Turret indecies <ARRAY>
 *
 * Public: Yes
 */
#include "script_component.hpp"

params [["_vehicle", objNull, [objNull]]];

fullCrew [_vehicle, "gunner", true] apply {_x select 3} param [0, []] // return
