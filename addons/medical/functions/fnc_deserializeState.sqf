#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Deserializes the medical state of a unit and applies it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: State as JSON <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, _json] call ace_medical_fnc_deserializeState
 *
 * Public: Yes
 */
params [["_unit", objNull, [objNull]], ["_json", "{}", [""]]];

// Don't run in scheduled environment
if (canSuspend) exitWith {
    [FUNC(deserializeState), _this] call CBA_fnc_directCall
};

if (isNull _unit) exitWith {};
if (!local _unit) exitWith { ERROR_1("unit [%1] is not local",_unit) };

// If unit is not initialized yet, wait until event is raised
if !(_unit getVariable [QGVAR(initialized), false]) exitWith {
    [QEGVAR(medical_status,initialized), {
        params ["_unit"];
        _thisArgs params ["_target"];

        if (_unit == _target) then {
            _thisArgs call FUNC(deserializeState);
            [_thisType, _thisId] call CBA_fnc_removeEventHandler;
        };
    }, _this] call CBA_fnc_addEventHandlerArgs;
};

private _state = [_json] call CBA_fnc_parseJSON;

// Migration from old array wounding storage serialized in old versions (<= 3.16.0)
{
    if ((_state getVariable [_x, createHashMap]) isEqualType []) then {
        private _migratedWounds = createHashMap;

        {
            _x params ["_class", "_bodyPartIndex", "_amountOf", "_bleeding", "_damage"];

            private _partWounds = _migratedWounds getOrDefault [ALL_BODY_PARTS select _bodyPartIndex, [], true];
            _partWounds pushBack [_class, _amountOf, _bleeding, _damage];
        } forEach (_state getVariable _x);

        _state setVariable [_x, _migratedWounds];
    };
} forEach [VAR_OPEN_WOUNDS, VAR_BANDAGED_WOUNDS, VAR_STITCHED_WOUNDS];

// Convert wound entries from hashmaps back to positional arrays for the ACE engine
private _convertWoundsBack = {
    params ["_wounds"];
    if (_wounds isEqualTo createHashMap) exitWith { _wounds };
    // CBA_fnc_parseJSON returns nested CBA_namespaces (Location type), not HashMaps
    if (typeName _wounds == "LOCATION") then {
        private _woundKeys = allVariables _wounds;
        private _woundValues = _woundKeys apply {_wounds getVariable _x};
        _wounds = _woundKeys createHashMapFromArray _woundValues;
    };
    private _result = createHashMap;
    {
        _result set [_x, (_wounds get _x) apply {
            private _wound = _x;
            if (typeName _wound == "LOCATION") then {
                private _woundKeys = allVariables _wound;
                private _woundValues = _woundKeys apply {_wound getVariable _x};
                _wound = _woundKeys createHashMapFromArray _woundValues;
            };
            if (_wound isEqualType createHashMap) then {
                [_wound getOrDefault ["classComplex", 0], _wound getOrDefault ["amountOf", 0],
                 _wound getOrDefault ["bleedingRate", 0], _wound getOrDefault ["woundDamage", 0]]
            } else { _wound }
        }]
    } forEach keys _wounds;
    _result
};
{
    private _wounds = _state getVariable [_x, createHashMap];
    _state setVariable [_x, [_wounds] call _convertWoundsBack];
} forEach [VAR_OPEN_WOUNDS, VAR_BANDAGED_WOUNDS, VAR_STITCHED_WOUNDS];

// Set medical variables
{
    _x params ["_var", "_default"];
    private _value = _state getVariable _x;

    // Handle wound hashmaps deserialized as CBA_namespaces
    if (typeName _value == "LOCATION") then {
        private _keys = allVariables _value;
        private _values = _keys apply {_value getVariable _x};
        _value = _keys createHashMapFromArray _values;
    };

    // Treat null as nil
    if (_value isEqualTo objNull) then {
        _value = _default;
    };

    _unit setVariable [_var, _value, true];
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
    // Offset needs to be converted
    // [VAR_MEDICATIONS, []]
];

// Reset timers
_unit setVariable [QEGVAR(medical,lastWakeUpCheck), nil];

// Convert medications offset to time
private _medications = _state getVariable [VAR_MEDICATIONS, []];
_medications = _medications apply {
    if (_x isEqualType createHashMap) then {
        [_x getOrDefault ["medication", ""], _x getOrDefault ["timeOffset", 0],
         _x getOrDefault ["timeToMaxEffect", 0], _x getOrDefault ["maxTimeInSystem", 0],
         _x getOrDefault ["hrAdjust", 0], _x getOrDefault ["painAdjust", 0],
         _x getOrDefault ["flowAdjust", 0], _x getOrDefault ["dose", 0]]
    } else { _x }
};
{
    _x set [1, _x#1 + CBA_missionTime];
} forEach _medications;
_unit setVariable [VAR_MEDICATIONS, _medications, true];

// Update effects
[_unit] call EFUNC(medical_engine,updateDamageEffects);
[_unit] call EFUNC(medical_status,updateWoundBloodLoss);

// Transition within statemachine
private _currentState = [_unit, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
private _targetState = _state getVariable [QGVAR(statemachineState), "Default"];
[_unit, GVAR(STATE_MACHINE), _currentState, _targetState] call CBA_statemachine_fnc_manualTransition;

// Manually call wake up tranisition if necessary
if (_currentState in ["Unconscious", "CardiacArrest"] && {_targetState in ["Default", "Injured"]}) then {
    [_unit, false] call EFUNC(medical_status,setUnconsciousState);
};

// Convert triage card entries from hashmaps back to positional arrays
private _triageCard = _unit getVariable [QEGVAR(medical,triageCard), []];
_triageCard = _triageCard apply {
    if (_x isEqualType createHashMap) then {
        [_x getOrDefault ["item", ""], _x getOrDefault ["count", 0], _x getOrDefault ["timestamp", 0]]
    } else { _x }
};
_unit setVariable [QEGVAR(medical,triageCard), _triageCard, true];

// Convert occluded medications entries from hashmaps back to positional arrays
private _occludedMeds = _unit getVariable [QEGVAR(medical,occludedMedications), nil];
if (!isNil "_occludedMeds") then {
    _occludedMeds = _occludedMeds apply {
        if (_x isEqualTo [] || !(_x isEqualType createHashMap)) then { _x } else {
            [_x getOrDefault ["partIndex", 0], _x getOrDefault ["className", ""]]
        }
    };
    _unit setVariable [QEGVAR(medical,occludedMedications), _occludedMeds, true];
};

// Convert IV bag entries from hashmaps back to positional arrays
private _ivBags = _unit getVariable [QEGVAR(medical,ivBags), nil];
if (!isNil "_ivBags") then {
    _ivBags = _ivBags apply {
        if (_x isEqualType createHashMap) then {
            [_x getOrDefault ["volume", 0], _x getOrDefault ["type", ""],
             _x getOrDefault ["partIndex", 0], _x getOrDefault ["treatment", ""],
             _x getOrDefault ["rateCoef", 1], _x getOrDefault ["item", ""]]
        } else { _x }
    };
    _unit setVariable [QEGVAR(medical,ivBags), _ivBags, true];
};

// Set logs, 1s later due to logs being wiped on unit init
private _logs = _state getVariable [QGVAR(logs), []];
_logs = _logs apply {
    if (_x isEqualType createHashMap) then {
        [_x getOrDefault ["logType", ""], (_x getOrDefault ["entries", []]) apply {
            if (_x isEqualType createHashMap) then {
                [_x getOrDefault ["message", ""], _x getOrDefault ["timestamp", ""],
                 _x getOrDefault ["arguments", []], _x getOrDefault ["logType", ""]]
            } else { _x }
        }]
    } else { _x }
};
[{
    params ["_unit", "_logs"];

    private _allLogs = [];
    {
        _x params ["_variable", "_state"];

        _allLogs pushBack _variable;
        _unit setVariable [_variable, _state, true];
    } forEach _logs;

    _unit setVariable [QGVAR(allLogs), _allLogs, true];
}, [_unit, _logs], 1] call CBA_fnc_waitAndExecute;

// Manually activate if non-defaults are present
[_unit] call EFUNC(medical_engine,checkForMedicalActivity);

[QGVAR(deserialize), [_unit, _state]] call CBA_fnc_localEvent;

_state call CBA_fnc_deleteNamespace;
