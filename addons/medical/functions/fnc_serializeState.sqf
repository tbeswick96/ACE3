#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Serializes the medical state of a unit into a string.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Serialized state as JSON string <STRING>
 *
 * Example:
 * [player] call ace_medical_fnc_serializeState
 *
 * Public: Yes
 */
params [["_unit", objNull, [objNull]]];

private _state = [] call CBA_fnc_createNamespace;

// For variables, see: EFUNC(medical_status,initUnit)
{
    _x params ["_var"];
    _state setVariable [_var, _unit getVariable _x];
} forEach [
    [VAR_BLOOD_VOL, DEFAULT_BLOOD_VOLUME],
    [VAR_HEART_RATE, DEFAULT_HEART_RATE],
    [VAR_BLOOD_PRESS, [80, 120]],
    [VAR_PERIPH_RES, DEFAULT_PERIPH_RES],
    // State transition should handle this
    // [VAR_CRDC_ARRST, false],
    [VAR_HEMORRHAGE, 0],
    [VAR_PAIN, 0],
    [VAR_IN_PAIN, false],
    [VAR_PAIN_SUPP, 0],
    [VAR_OPEN_WOUNDS, createHashMap],
    [VAR_BANDAGED_WOUNDS, createHashMap],
    [VAR_STITCHED_WOUNDS, createHashMap],
    [VAR_FRACTURES, DEFAULT_FRACTURE_VALUES],
    // State transition should handle this
    // [VAR_UNCON, false],
    [VAR_TOURNIQUET, DEFAULT_TOURNIQUET_VALUES],
    [QEGVAR(medical,occludedMedications), nil],
    [QEGVAR(medical,ivBags), nil],
    [QEGVAR(medical,triageLevel), 0],
    [QEGVAR(medical,triageCard), []],
    [VAR_BODYPART_DAMAGE, DEFAULT_BODYPART_DAMAGE_VALUES]
    // Time needs to be converted
    // [VAR_MEDICATIONS, []]
];

// Convert medications time to offset
private _medications = +(_unit getVariable [VAR_MEDICATIONS, []]);
{
    _x set [1, _x#1 - CBA_missionTime];
} forEach _medications;
_medications = _medications apply {
    if (_x isEqualType createHashMap) then { _x } else {
        createHashMapFromArray [
            ["medication", _x#0], ["timeOffset", _x#1],
            ["timeToMaxEffect", _x#2], ["maxTimeInSystem", _x#3],
            ["hrAdjust", _x#4], ["painAdjust", _x#5],
            ["flowAdjust", _x#6], ["dose", _x#7]
        ]
    }
};
_state setVariable [VAR_MEDICATIONS, _medications];

// Medical statemachine state
private _currentState = [_unit, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
_state setVariable [QGVAR(statemachineState), _currentState];

// Logs
private _logs = (_unit getVariable [QGVAR(allLogs), []]) apply {[_x, _unit getVariable [_x, []]]};
TRACE_1("Saved",_logs);
_state setVariable [QGVAR(logs), _logs];

[QGVAR(serialize), [_unit, _state]] call CBA_fnc_localEvent;

// Convert wound entries from positional arrays to hashmaps
private _convertWounds = {
    params ["_wounds"];
    if (_wounds isEqualTo createHashMap) exitWith { _wounds };
    private _result = createHashMap;
    {
        _result set [_x, (_wounds get _x) apply {
            if (_x isEqualType createHashMap) then { _x } else {
                createHashMapFromArray [
                    ["classComplex", _x#0], ["amountOf", _x#1],
                    ["bleedingRate", _x#2], ["woundDamage", _x#3]
                ]
            }
        }]
    } forEach keys _wounds;
    _result
};
{
    private _wounds = _state getVariable [_x, createHashMap];
    _state setVariable [_x, [_wounds] call _convertWounds];
} forEach [VAR_OPEN_WOUNDS, VAR_BANDAGED_WOUNDS, VAR_STITCHED_WOUNDS];

// Convert triage card entries from positional arrays to hashmaps
private _triageCard = _state getVariable [QEGVAR(medical,triageCard), []];
_state setVariable [QEGVAR(medical,triageCard), _triageCard apply {
    if (_x isEqualType createHashMap) then { _x } else {
        createHashMapFromArray [["item", _x#0], ["count", _x#1], ["timestamp", _x#2]]
    }
}];

// Convert occluded medications entries from positional arrays to hashmaps
private _occludedMeds = _state getVariable [QEGVAR(medical,occludedMedications), nil];
if (!isNil "_occludedMeds") then {
    _state setVariable [QEGVAR(medical,occludedMedications), _occludedMeds apply {
        if (_x isEqualTo [] || _x isEqualType createHashMap) then { _x } else {
            createHashMapFromArray [["partIndex", _x#0], ["className", _x#1]]
        }
    }];
};

// Convert IV bag entries from positional arrays to hashmaps
private _ivBags = _state getVariable [QEGVAR(medical,ivBags), nil];
if (!isNil "_ivBags") then {
    _state setVariable [QEGVAR(medical,ivBags), _ivBags apply {
        if (_x isEqualType createHashMap) then { _x } else {
            createHashMapFromArray [
                ["volume", _x#0], ["type", _x#1], ["partIndex", _x#2],
                ["treatment", _x#3], ["rateCoef", _x#4], ["item", _x#5]
            ]
        }
    }];
};

// Convert log entries from positional arrays to hashmaps
private _logsConverted = _state getVariable [QGVAR(logs), []];
_state setVariable [QGVAR(logs), _logsConverted apply {
    if (_x isEqualType createHashMap) then { _x } else {
        createHashMapFromArray [
            ["logType", _x#0],
            ["entries", (_x#1) apply {
                if (_x isEqualType createHashMap) then { _x } else {
                    createHashMapFromArray [
                        ["message", _x#0], ["timestamp", _x#1],
                        ["arguments", _x#2], ["logType", _x#3]
                    ]
                }
            }]
        ]
    }
}];

// Serialize & return
private _json = [_state] call CBA_fnc_encodeJSON;
_state call CBA_fnc_deleteNamespace;
_json
