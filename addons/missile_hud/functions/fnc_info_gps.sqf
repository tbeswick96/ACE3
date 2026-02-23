#include "..\script_component.hpp"
/*
 * Author: PabstMirror
 * Generates HUD info for GPS seeker.
 *
 * Arguments:
 * 0: Idle text <STRING>
 * 1: Locked text <STRING>
 * 2: Unit <OBJECT>
 * 3: Vehicle <OBJECT>
 * 4: Ammo config <CONFIG>
 *
 * Return Value:
 * Element array <ARRAY>
 *
 * Example:
 * [["TEXT", "My Test", [1, 0.4, 5]]] call ace_missile_hud_fnc_info_gps
 *
 * Public: No
 */

params ["", "", "", "_vehicle", ""];

private _output = [["TEXT", "GPS", [1, 1, 1]]];

// Cruise missile planner stores target independently of the GPS dialog
private _cruiseSettings = _vehicle getVariable [QEGVAR(missileguidance,cruiseTargetSettings), []];
private _position = if (count _cruiseSettings >= 1) then {
    _cruiseSettings select 0
} else {
    ([] call EFUNC(missileguidance,gps_getAttackData)) param [0, [0, 0, 0]]
};

if (_position isNotEqualTo [0, 0, 0]) then {
    ([_position] call EFUNC(common,getMapGridFromPos)) params ["_easting", "_northing"];
    _output pushBack ["TEXT", format ["%1 %2", _easting, _northing], [1, 1, 1]];
} else {
    _output pushBack ["TEXT", "----- -----", [1, 1, 1]];
};

_output
