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

private _viewStart = AGLToASL (positionCameraToWorld [0,0,0]);
private _viewEnd = AGLToASL (positionCameraToWorld _direction);

private _viewVector = _viewStart vectorFromTo _viewEnd;
private _viewAngle = asin (_viewVector select 2);

private _v0x = cos _viewAngle * _velocity;
private _v0z = sin _viewAngle * _velocity;

private _headOffest = call FUNC(getHeadOffset);

private _throwDir = getDirVisual player + _headOffest;
private _flyDirSin = sin _throwDir;
private _flyDirCos = cos _throwDir;
private _sPosx = (getPosASLVisual GVAR(ActiveGrenadeItem)) select 0;
private _sPosy = (getPosASLVisual GVAR(ActiveGrenadeItem)) select 1;
private _sPosz = (getPosASLVisual GVAR(ActiveGrenadeItem)) select 2;
private _prevTrajASL = [_sPosx,_sPosy, (getPosASLVisual GVAR(ActiveGrenadeItem)) select 2];

private _newTrajASL = [];
private _newTrajATL = [];
GVAR(PathData) = [];

for "_i" from 0.05 to 1.45 step 0.1 do {
    private _dx = _v0x * _i;
    private _dy = _v0z * _i - 4.905 * _i ^ 2;

    _newTrajASL = [_sPosx + _flyDirSin * _dx, _sPosy + _flyDirCos * _dx, _sPosz + _dy];
    _newTrajATL = ASLtoATL _newTrajASL;
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

        GVAR(PathData) pushBack [_col, _newTrajATL, _iDim];
    };

    if (_cross > 0) exitWith {};

    _prevTrajASL = _newTrajASL;
};

reverse GVAR(PathData);
// To get the sort order correct from our POV, particularly when using outlined dots
{
    _x params ["_col", "_newTrajATL", "_iDim"];
    drawIcon3D ["\a3\ui_f\data\gui\cfg\Hints\icon_text\group_1_ca.paa", _col, _newTrajATL, _iDim, _iDim, 0, "", 2];
} forEach GVAR(PathData);
