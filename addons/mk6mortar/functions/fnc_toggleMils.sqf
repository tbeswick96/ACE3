/*
 * Author: PabstMirror
 * Toggles the mortart to show mils or degrees
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Player <OBJECT>
 *
 * Return Value:
 * No
 *
 * Example:
 * [mortar,bob] call ace_mk6mortar_fnc_toggleMils;
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_2(_mortarVeh,_unit);

private _currentSetting = _mortarVeh getVariable [QGVAR(useMils), true];
_mortarVeh setVariable [QGVAR(useMils), (!_currentSetting)];
