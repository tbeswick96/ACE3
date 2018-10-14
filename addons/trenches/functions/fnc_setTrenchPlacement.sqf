#include "script_component.hpp"
/*
 * Author: Garth 'L-H' de Wet, Ruthberg, edited by commy2 for better MP and eventual AI support and esteldunedain
 * Sets trench placement
 *
 * Arguments:
 * 0: unit <OBJECT>
 * 1: trench <OBJECT>
 * 2: trench id <NUMBER>
 * 3: position ASL <ARRAY>
 * 4: vector dir and up <ARRAY>
 * 5: progress <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [ACE_player, TrenchObj, 2, [0,0,0], [[0,0,0],[0,0,0]], 0.5] call ace_trenches_fnc_setTrenchPlacement
 *
 * Public: No
 */

params ["_unit", "_trench", "_trenchId", "_pos", "_vecDirAndUp", "_progress", "_digTime"];

// If the progress bar was cancelled, cancel elevation
// We use an uid to avoid any chance of an older trench being raised when a new one is built
if (_unit getVariable [QGVAR(isDiggingId), -1] != _trenchId) exitWith {};

_trench setPosASL _pos;
_trench setVectorDirAndUp _vecDirAndUp;
if (!isNil "_digTime") then {
    EGVAR(advanced_fatigue,anReserve) = (EGVAR(advanced_fatigue,anReserve) - ((_digTime) * GVAR(buildFatigueFactor))) max 0;
    EGVAR(advanced_fatigue,anFatigue) = (EGVAR(advanced_fatigue,anFatigue) + (((_digTime) * GVAR(buildFatigueFactor))/120)) min 1;
};

// Save progress local
_trench setVariable [QGVAR(progress), _progress];
