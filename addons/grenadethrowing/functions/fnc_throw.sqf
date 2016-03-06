/*
 * Author: Dslyecxi, Jonpas
 * Throw grenade.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_throw
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

// If the grenade's not already cooked, create the "real" one
if (!GVAR(CookingGrenade)) then {
    [_unit, GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
};

private _currentThrowable = (currentThrowable _unit) select 0;
private _muzzle = [_currentThrowable] call FUNC(getMuzzle);

[QGVAR(throwFiredEH), [
    _unit, // unit
    "Throw", // weapon
    _muzzle, // muzzle
    _muzzle, // mode
    GVAR(ActiveGrenadeType), // ammo
    _currentThrowable, // magazine
    GVAR(ActiveGrenadeItem) // projectile
]] call EFUNC(common,globalEvent);

_unit removeItem _currentThrowable;

// Stuff we need to know
private _direction = [THROWSTYLE_NORMAL_DIR, THROWSTYLE_HIGH_DIR] select (GVAR(ThrowType) == "high");
private _velocity = [GVAR(CurrentThrowSpeed), THROWSTYLE_HIGH_VEL] select (GVAR(ThrowType) == "high");
private _vup = [THROWSTYLE_NORMAL_VECTORUP, THROWSTYLE_HIGH_VECTORUP] select (GVAR(ThrowType) == "high");

if (GVAR(CtrlHeld)) then {
    _direction = THROWSTYLE_EXTARM_DIR;
    _velocity = THROWSTYLE_EXTARM_VEL;
};

private _p2 = (eyePos _unit) vectorAdd (positionCameraToWorld _direction) vectorDiff (positionCameraToWorld [0, 0, 0]);
private _p1 = AGLtoASL (GVAR(ActiveGrenadeItem) modelToWorldVisual [0, 0, 0]);

private _newVelocity = (_p1 vectorFromTo _p2) vectorMultiply _velocity;

// Adjust for throwing from inside vehicles, where we have a vehicle-based velocity that can't be compensated for by a human
if (vehicle _unit != _unit) then {
    _newVelocity = _newVelocity vectorAdd (velocity (vehicle _unit));
};

// Drop if unit dies during throw process
if (alive _unit) then {
    GVAR(ActiveGrenadeItem) setVectorUp _vup; // This was null at start sometimes
    GVAR(ActiveGrenadeItem) setVelocity _newVelocity;
};

[_unit, "Completed a throw fully"] call FUNC(exitThrowMode);
