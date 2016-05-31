/*
 * Author: BaerMitUmlaut
 * Checks if the unit can detach the helicopter FRIES.
 *
 * Arguments:
 * 0: The helicopter itself <OBJECT>
 *
 * Return Value:
 * Able to detach FRIES <BOOL>
 *
 * Example:
 * [_vehicle] call ace_fastroping_fnc_canPrepareFRIES
 *
 * Public: No
 */

#include "script_component.hpp"
params ["_vehicle"];

private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;

(
	isNumber (_config >> QGVAR(enabled)) && {
		(getNumber (_config >> QGVAR(enabled)) == 2)
	} && {
		!(isNull (_vehicle getVariable [QGVAR(FRIES), objNull]))
	} && {
		((getPos _vehicle) select 2) < 5
	}
)
