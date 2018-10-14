/*
 * Author: chris579
 * Inits a trench
 *
 * Arguments:
 * 0: trench <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [TrenchObj] call ace_trenches_fnc_initTrench
 *
 * Public: No
 */
#include "script_component.hpp"
params [
    ["_object", objnull, [objNull]]
];

if (is3DEN) exitWith {
    [_object] call FUNC(initTrench3DEN);
};

if (local _object) then {
    // Has to be spawned to ensure MP compatibility
    _object spawn {
        private _texture = [_this] call FUNC(getSurfaceTexturePath);
        _this setObjectTextureGlobal [0, _texture];
    };
};
