/*
 * Author: Glowbal
 * Unload a person from a vehicle
 *
 * Arguments:
 * 0: unit <OBJECT>
 *
 * Return Value:
 * Returns true if succesfully unloaded person <BOOL>
 *
 * Example:
 * [hurtGuy] call ace_common_fnc_unloadPerson
 *
 * Public: No
 */
#include "script_component.hpp"

#define GROUP_SWITCH_ID QFUNC(loadPerson)

params ["_unit"];

private _vehicle = vehicle _unit;

if (_vehicle == _unit) exitWith {false};

if (speed _vehicle > 1 || {((getPos _vehicle) select 2) > 2}) exitWith {false};

if (!isNull _vehicle) then {
    ["unloadPersonEvent", [_unit], [_unit, _vehicle]] call EFUNC(common,targetEvent);
};

true
