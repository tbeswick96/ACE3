/*
 * Author: commy2
 * Recalculate the units loadCoef to emulate a mass added to uniform, vest or backpack.
 *
 * Arguments:
 * 0: The Unit (usually the player) <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

if (isNull _unit) exitWith {};

// add sum of virtual loads
private _virtualLoad = 0;

{
    _virtualLoad = _virtualLoad + (_x getVariable [QGVAR(vLoad), 0]);
} forEach [
    _unit,
    uniformContainer _unit,
    vestContainer _unit,
    backpackContainer _unit
];

// get absolute vanilla load
private _absLoad = getNumber (configFile >> "CfgInventoryGlobalVariable" >> "maxSoldierLoad");

// try to preserve other changes to the "LoadCoef" unitTrait
private _loadCoef = _unit getVariable QGVAR(loadCoef);

if (isNil "_loadCoef") then {
    _loadCoef = _unit getUnitTrait "loadCoef";
    _unit setVariable [QGVAR(loadCoef), _loadCoef, true];
};

// calc. new "virtual" loadCoef
private _virtualLoadCoef = (1 + _virtualLoad / _absLoad) * _loadCoef;

_unit setUnitTrait ["loadCoef", _virtualLoadCoef];
