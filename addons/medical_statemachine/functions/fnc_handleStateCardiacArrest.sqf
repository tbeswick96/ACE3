#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut, Tim Beswick
 * Cardiac arrest per-tick handler. With endpoint-based timer
 * (cardiacArrestEndTime), no decrement is needed normally. While CPR is
 * active, the endpoint is pushed forward by 0.5 * elapsed to model the
 * 50% slowdown. Broadcast every 5 seconds during CPR (only changes then).
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_statemachine_fnc_handleStateCardiacArrest
 *
 * Public: No
 */

params ["_unit"];

if (!alive _unit || {!local _unit}) exitWith {};

[_unit] call EFUNC(medical_vitals,handleUnitVitals);

private _lastTick = _unit getVariable [QGVAR(cardiacArrestLastTick), CBA_missionTime];
private _timeDiff = (CBA_missionTime - _lastTick) min 10;

private _receivingCPR = alive (_unit getVariable [QEGVAR(medical,CPR_provider), objNull]);
if (!_receivingCPR) exitWith {
    _unit setVariable [QGVAR(cardiacArrestLastTick), CBA_missionTime];
};

if (_timeDiff < 1) exitWith {};
_unit setVariable [QGVAR(cardiacArrestLastTick), CBA_missionTime];

private _endTime = _unit getVariable [QGVAR(cardiacArrestEndTime), -1];
if (_endTime < 0) exitWith {};

_endTime = _endTime + (_timeDiff * 0.5);

private _lastBroadcast = _unit getVariable [QGVAR(cardiacArrestLastBroadcast), 0];
private _broadcast = (CBA_missionTime - _lastBroadcast) >= 5;
if (_broadcast) then {
    _unit setVariable [QGVAR(cardiacArrestLastBroadcast), CBA_missionTime];
};
_unit setVariable [QGVAR(cardiacArrestEndTime), _endTime, _broadcast];

TRACE_3("cardiacArrest CPR push",_unit,_timeDiff,_endTime);
