/*
 * Author: BaerMitUmlaut
 * Checks if the unit can prepare the helicopters FRIES.
 *
 * Arguments:
 * 0: The helicopter itself <OBJECT>
 *
 * Return Value:
 * Able to prepare FRIES <BOOL>
 *
 * Example:
 * [_vehicle] call ace_fastroping_fnc_canPrepareFRIES
 *
 * Public: No
 */

#include "script_component.hpp"
params ["_vehicle"];

if (_vehicle isKindOf "CAManBase") then {
	_vehicle = vehicle _vehicle;
};
[_vehicle] call FUNC(equipFRIES);
