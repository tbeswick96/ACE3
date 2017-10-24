/*
 * Author: commy2
 *
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Number <NUMBER>
 *
 * Example:
 * call ace_vector_fnc_getRelativeDistance
 *
 * Public: No
 */

#include "script_component.hpp"

private _distanceP1 = GVAR(pData) select 0;
private _directionP1 = GVAR(pData) select 1;
private _azimuthP1 = _directionP1 select 0;
private _inclinationP1 = _directionP1 select 1;

private _distanceP2 = call FUNC(getDistance);
private _directionP2 = call FUNC(getDirection);
private _azimuthP2 = _directionP2 select 0;
private _inclinationP2 = _directionP2 select 1;


private _relDirection = sqrt ((_azimuthP1 - _azimuthP2) ^ 2 + (_inclinationP1 - _inclinationP2) ^ 2);
private _relDistance = sqrt (_distanceP1 ^ 2 + _distanceP2 ^ 2 - 2 * _distanceP1 * _distanceP2 * cos _relDirection);

if (_distanceP1 < -999 || {_distanceP2 < -999}) exitWith {
    -1000    // return
};

_relDistance
