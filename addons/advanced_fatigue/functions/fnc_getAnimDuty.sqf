/*
 * Author: BaerMitUmlaut
 * Calculates the duty of the current animation.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Animation name <STRING>
 *
 * Return Value:
 * Duty <NUMBER>
 *
 * Example:
 * [player, "AidlPercMstpSlowWrflDnon_G05"] call ace_advanced_fatigue_fnc_getAnimDuty
 *
 * Public: No
 */
#include "script_component.hpp"
params ["_unit", "_animName"];

private _duty = 1;
private _animType = _animName select [1, 3];

GVAR(isSwimming) = false;

if (_animType in ["idl", "mov"]) then {
    switch (_animName select [5, 3]) do {
        case ("knl"): {
            _duty = 1.5;
        };
        case ("pne"): {
            _duty = 12;
        };
        default {
            _duty = 1;
        };
    };

    if (currentWeapon _unit != handgunWeapon _unit) then {
        if (_animName select [13, 3] == "ras") then {
            // low ready jog
            _duty = _duty * 1.2;
            if (_animName select [9, 3] == "tac") then {
                // high ready jog/walk
                _duty = _duty * 1.5;
            };
        };
    };
} else {
    // swimming and diving
    if (_animType in ["swm", "ssw", "bsw", "dve", "sdv", "bdv"]) then {
        _duty = 5;
        GVAR(isSwimming) = true;
    };
};

_duty
