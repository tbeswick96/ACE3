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

private _vehicle = GVAR(currentAircraft);
private _combos = GVAR(comboBoxes);
private _comboPylons = [];
{
    _comboPylons pushBack ((_x select 0) lbData (lbCurSel (_x select 0)));
} forEach _combos;

[QGVAR(onButtonApplyLocal), [_vehicle, _comboPylons], _vehicle] call CBA_fnc_targetEvent;
