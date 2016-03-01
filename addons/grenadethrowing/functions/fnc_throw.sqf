/*
 * Author: Dslyecxi, Jonpas
 * Throw grenade.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_throw
 *
 * Public: No
 */
#include "script_component.hpp"

private _currentThrowable = currentThrowable player;

// Check to see if we have anything to throw.
if (count _currentThrowable < 1 || {_currentThrowable select 0 == ""}) exitWith {
    ["No valid throwables"] call FUNC(exitThrowMode); // If we've exhausted a type of grenade, currentThrowable select 0 will have a blank string
};

// Since we have something to throw, let's create it. By activating GrenadeInHand, the PFH creates a grenade
private _dropType = getText (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "ammo");

if (_dropType == "") exitWith {
    ["No valid throwables (check 2)"] call FUNC(exitThrowMode);
};

GVAR(ActiveGrenadeType) = _dropType;
GVAR(CookingGrenade) = false; // Can't be cooking, just pulled it.
GVAR(CurrentThrowSpeed) = 0;
GVAR(LastGrenadeTypeChecked) = "";
GVAR(GrenadeInHand) = true;

// PFH is maintaining at this point, we're just waiting for a throw, or exit if we die.
[{
    GVAR(ThrowGrenade) || !alive player
}, {
    if (GVAR(CancelThrow) || !alive player || count (currentThrowable player) < 1) exitWith {
        ["Throw check (cancel? valid? alive? etc), apparently not!"] call FUNC(exitThrowMode);
    };

    // Make it real at the end.
    player playAction "ThrowGrenade";

    // If CTRL is held, we don't delay. Otherwise we wait for the playAction to complete, which is roughly 0.3 seconds.
    private _waitTime = 0.3;
    if (GVAR(CtrlHeld)) then {
        _waitTime = 0.01;
    };

    [{
        // If the grenade's not already cooked, create the "real" one
        if (!GVAR(CookingGrenade)) then {
            [GVAR(ActiveGrenadeItem), GVAR(ActiveGrenadeType)] call FUNC(cook);
        };

        // Handle removing stuff from our inventory, working on BI bugs
        private _typeCount = 0;
        private _typeGrenCheck = (currentThrowable player) select 0;

        {
            if (_x == _typeGrenCheck) then {
                _typeCount = _typeCount + 1;
            };
        } forEach (magazines player);

        // Works around a bug where removing one will make them unselectable
        if (_typeCount > 1) then {
            TRACE_1("Removing Throwable (2)",_typeGrenCheck);
            player removeMagazine _typeGrenCheck;
            player removeMagazine _typeGrenCheck;
            player addMagazine _typeGrenCheck;
        } else {
            TRACE_1("Removing Throwable (1)",_typeGrenCheck);
            player removeMagazine _typeGrenCheck;
        };

        // Stuff we need to know
        private _direction = GVAR(ThrowStyle_Normal_Direction);
        private _velocity = GVAR(CurrentThrowSpeed);
        private _vup = [0, 1, 1];

        if (GVAR(ThrowType) == "under") then {
            _direction = GVAR(ThrowStyle_Under_Direction);
            _velocity = GVAR(ThrowStyle_Under_Velocity);
            _vup = [1, 0, 0];
        };

        // Calculate the throw vector
        private _newVelocity = [0, 0, 0];

        private _posFin = AGLToASL (positionCameraToWorld GVAR(CameraOffset)); // TrackIR throwing

        if (!GVAR(CtrlHeld)) then {
            GVAR(ActiveGrenadeItem) setPosASL _posFin;
        };

        if (GVAR(CtrlHeld)) then {
            _direction = [0, 200, 500];
            _velocity = 3;
        };

        // These are both AGL commands
        private _p2 = AGLtoASL (positionCameraToWorld _direction); // TrackIR throwing
        private _p1 = AGLtoASL (GVAR(ActiveGrenadeItem) modelToWorldVisual [0, 0, 0]);

        private _unitV = (vectorNormalized (_p1 vectorFromTo _p2)) vectorMultiply _velocity;

        if (vehicle player == player) then {
            // This method assumes the ability for a human to instinctively provide upper-body throw stabilization to prevent a grenade from being too influenced by how they're moving
            _newVelocity = [0, 0, 0] vectorAdd _unitV;
        } else {
            // This method would be for things like the Littlebird throw-from-vehicles, where we have a vehicle-based velocity that can't be compensated for by a human
            _newVelocity = (velocity (vehicle player)) vectorAdd _unitV;
        };

        // Should mean that if we die, it just drops
        if (alive player) then {
            private _startTime = time;
            private _timeOut = 1;

            [{
                params ["_startTime", "_timeOut"];
                !isNull GVAR(ActiveGrenadeItem) || time > _startTime + _timeOut
            }, {
                if (isNull GVAR(ActiveGrenadeItem)) exitWith {
                    ["Grenade was still null when trying to throw :( (removed a grenade in the process)"] call FUNC(exitThrowMode);
                };

                params ["", "", "_vup", "_newVelocity"];

                GVAR(ActiveGrenadeItem) setVectorUp _vup; // This was null at start sometimes

                private _grenadeThrowStartPos = AGLtoASL (getPosVisual GVAR(ActiveGrenadeItem));

                GVAR(ActiveGrenadeItem) setPosASL _grenadeThrowStartPos;
                GVAR(ActiveGrenadeItem) setVelocity _newVelocity;

                // Attempted failsafe for the drop-grenade issue.
                [{
                    params ["_grenadeThrowStartPos", "_newVelocity"];

                    GVAR(ActiveGrenadeItem) setPosASL _grenadeThrowStartPos;
                    GVAR(ActiveGrenadeItem) setVelocity _newVelocity;
                }, [_grenadeThrowStartPos, _newVelocity], 0.01] call EFUNC(common,waitAndExecute);
                [{
                    params ["_grenadeThrowStartPos", "_newVelocity"];

                    GVAR(ActiveGrenadeItem) setPosASL _grenadeThrowStartPos;
                    GVAR(ActiveGrenadeItem) setVelocity _newVelocity;
                }, [_grenadeThrowStartPos, _newVelocity], 0.02] call EFUNC(common,waitAndExecute);

                GVAR(LastThrownTime) = time;
            }, [_startTime, _timeOut, _vup, _newVelocity]] call EFUNC(common,waitUntilAndExecute);

        };

        ["Completed a throw fully"] call FUNC(exitThrowMode);
    }, [], _waitTime] call EFUNC(common,waitAndExecute);

}, []] call EFUNC(common,waitUntilAndExecute);
