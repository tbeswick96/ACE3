/*
 * Author: 654wak654
 * Applies the current configuration of pylons to the aircraft
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_aircraft_fnc_onButtonApply
 *
 * Public: No
 */
#include "script_component.hpp"

[QGVAR(onButtonApplyLocal), [GVAR(currentAircraft), GVAR(comboBoxes)], GVAR(currentAircraft)] call CBA_fnc_targetEvent;
