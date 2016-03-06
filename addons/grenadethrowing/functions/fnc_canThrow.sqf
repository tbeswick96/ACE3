/*
 * Author: Jonpas
 * Checks if a grenade can be prepared.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Can Throw Grenade <BOOL>
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_canThrow
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(GrenadeInHand)) exitWith {false};

params ["_unit"];

if (vehicle _unit != _unit) exitWith {
    private _startPos = eyePos _unit;
    private _aimLinePos = AGLToASL (positionCameraToWorld [0, 0, 5]);
    private _intersections = lineIntersectsSurfaces [_startPos, _aimLinePos, _unit, objNull, true, 1, "GEOM", "FIRE"];
    TRACE_1("Intersections",_intersections);

    private _exit = true;
    {
        if ((vehicle _unit) in (_x select 3)) exitWith {
            _exit = false;
        };
    } forEach _intersections;

    _exit
};

true
