/*
 * Author: Zapat, Dslyecxi, Jonpas
 * Draw3D handler.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_draw3d
 *
 * Public: No
 */
#include "script_component.hpp"

#ifdef DEBUG_MODE_FULL
hintSilent format ["
    Cancel: %1\n
    ToggleThrow: %2\n
    Throw: %3\n
    InHand: %4\n
    Cook: %5\n
    TSL: %6\n
    TBT: %7\n
    actGren: %8
    ",
    GVAR(CancelThrow),
    GVAR(ToggleThrowMode),
    GVAR(ThrowGrenade),
    GVAR(GrenadeInHand),
    GVAR(CookingGrenade),
    time < GVAR(LastTimeSwitchKeyPressed) + 0.5,
    time - GVAR(LastThrownTime) < GVAR(TimeBetweenThrows),
    GVAR(ActiveGrenadeItem)
];
#endif


if (!GVAR(GrenadeInHand)) exitWith {};
if (isNil QGVAR(ActiveGrenadeItem)) exitWith {};

private _direction = GVAR(ThrowStyle_Normal_Direction);
private _velocity = GVAR(CurrentThrowSpeed);

if (GVAR(ThrowType) == "under") then {
    _direction = GVAR(ThrowStyle_Under_Direction);
    _velocity = GVAR(ThrowStyle_Under_Velocity);
};

private _viewStart = AGLToASL (positionCameraToWorld [0, 0, 0]);
private _viewEnd = AGLToASL (positionCameraToWorld _direction);

private _initialVelocity = (vectorNormalized (_viewEnd vectorDiff _viewStart)) vectorMultiply _velocity;
private _prevTrajASL = getPosASLVisual GVAR(ActiveGrenadeItem);

private _pathData = [];

for "_i" from 0.05 to 1.45 step 0.1 do {
    private _newTrajASL = _prevTrajASL vectorAdd (_initialVelocity vectorMultiply _i) vectorAdd ([0, 0, 0.5 * -9.8] vectorMultiply (_i * _i));
    private _newTrajATL = ASLtoAGL _newTrajASL;
    private _cross = 0;

    if (_newTrajATL distance (getPosATL player) <= 20) then {
        if (_newTrajATL select 2 <= 0) then {
            _cross = 1
        } else {
            if (lineIntersects [_prevTrajASL, _newTrajASL]) then {
                _cross = 2;
            };
        };

        private _iDim = linearConversion [20, 0, _newTrajATL distance (getPosATL player), 0.3, 2.5, true];
        private _alpha = linearConversion [20, 0, _newTrajATL distance (getPosATL player), 0.05, 0.7, true];
        private _movePerc = linearConversion [3, 0, vectorMagnitude (velocity player), 0, 1, true];
        _alpha = _alpha * _movePerc;

        private _col = [ [1, 1, 1, _alpha], [0, 1, 0, _alpha], [1, 0, 0, _alpha] ] select _cross;

        if (_cross != 2 && lineIntersects [eyePos player, _newTrajASL]) then {
            _col set [3, 0.1]
        };

        _pathData pushBack [_col, _newTrajATL, _iDim];
    };

    if (_cross > 0) exitWith {};

    _prevTrajASL = _newTrajASL;
};

reverse _pathData;
// To get the sort order correct from our POV, particularly when using outlined dots
{
    _x params ["_col", "_newTrajATL", "_iDim"];
    drawIcon3D ["\a3\ui_f\data\gui\cfg\Hints\icon_text\group_1_ca.paa", _col, _newTrajATL, _iDim, _iDim, 0, "", 2];
} forEach _pathData;
