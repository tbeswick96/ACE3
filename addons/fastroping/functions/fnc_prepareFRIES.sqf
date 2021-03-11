#include "script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Prepares the helicopters FRIES.
 *
 * Arguments:
 * 0: A helicopter with deployed ropes <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle] call ace_fastroping_fnc_prepareFRIES
 *
 * Public: No
 */
params ["_vehicle"];

//Stage indicator: 0 - travel mode; 1 - preparing/stowing FRIES; 2 - FRIES ready; 3 - ropes deployed
_vehicle setVariable [QGVAR(deploymentStage), 1, true];

private _config = configOf _vehicle;
private _waitTime = 0;
if (isText (_config >> QGVAR(onPrepare))) then {
    _waitTime = [_vehicle] call (missionNamespace getVariable (getText (_config >> QGVAR(onPrepare))));
};

[{
    _this setVariable [QGVAR(deploymentStage), 2, true];
}, _vehicle, _waitTime] call CBA_fnc_waitAndExecute;
