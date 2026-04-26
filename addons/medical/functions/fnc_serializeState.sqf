#include "..\script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Serializes the medical state of a unit. Returns a JSON string by default;
 * pass _asJson=false to get a native HashMap and skip the encode step
 * (avoids double-encode when the caller is going to encode again itself).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Return as JSON string <BOOL> (default: true)
 *
 * Return Value:
 * Serialized state <STRING|HASHMAP>
 *
 * Example:
 * [player] call ace_medical_fnc_serializeState
 * [player, false] call ace_medical_fnc_serializeState
 *
 * Public: Yes
 */
params [["_unit", objNull, [objNull]], ["_asJson", true, [false]]];

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
_state setVariable [VAR_MEDICATIONS, _medications];

// Medical statemachine state
private _currentState = [_unit, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
_state setVariable [QGVAR(statemachineState), _currentState];

// Logs
private _logs = ((_unit getVariable [QGVAR(allLogs), []]) select {_x isEqualType ""}) apply {[_x, _unit getVariable [_x, []]]};
TRACE_1("Saved",_logs);
_state setVariable [QGVAR(logs), _logs];

[QGVAR(serialize), [_unit, _state]] call CBA_fnc_localEvent;

// TEMPORARY: coerce poisoned wound entries (HashMap/Namespace) to positional
// arrays. Carry-over from the brief 2026-03-17 → 2026-03-22 build that wrote
// wounds as hashmaps; cleared once all profiles cycle through this save path.
// Remove this block after the next full modpack release ships and profiles
// have been rewritten at least once.
{
    private _wounds = _state getVariable [_x, createHashMap];
    if (_wounds isEqualType createHashMap) then {
        {
            _y = _y apply {
                switch (true) do {
                    case (_x isEqualType []): { _x };
                    case (_x isEqualType createHashMap): {
                        [_x getOrDefault ["classComplex", 0], _x getOrDefault ["amountOf", 0], _x getOrDefault ["bleedingRate", 0], _x getOrDefault ["woundDamage", 0]]
                    };
                    case (typeName _x == "LOCATION"): {
                        [_x getVariable ["classComplex", 0], _x getVariable ["amountOf", 0], _x getVariable ["bleedingRate", 0], _x getVariable ["woundDamage", 0]]
                    };
                    default { [0, 0, 0, 0] };
                };
            };
            _wounds set [_x, _y];
        } forEach _wounds;
    };
} forEach [VAR_OPEN_WOUNDS, VAR_BANDAGED_WOUNDS, VAR_STITCHED_WOUNDS];

// Convert namespace → native HashMap so callers (and CBA_fnc_encodeJSON below)
// see a single self-describing structure instead of an opaque namespace.
private _hash = createHashMapFromArray ((allVariables _state) apply {[_x, _state getVariable _x]});
_state call CBA_fnc_deleteNamespace;

if (_asJson) exitWith {
    [_hash] call CBA_fnc_encodeJSON
};

_hash
