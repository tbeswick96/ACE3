/*
 * Author: Dslyecxi, Jonpas
 * Handle all the changes.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit] call ace_grenadethrowing_fnc_pfh
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_args", "_idPFH"];

if (!GVAR(GrenadeInHand)) exitWith {
    [_idPFH] call CBA_fnc_removePerFrameHandler;
};

_args params ["_unit"];

if (dialog) exitWith {
    [_unit, "In dialog"] call FUNC(exitThrowMode);
};

private _exit = false;

if (!([_unit] call FUNC(canPrepareGrenade))) exitWith {
    [_unit, "Cannot interact or use weapon"] call FUNC(exitThrowMode);
};

private _currentThrowable = currentThrowable _unit;

// These handle if we run out of grenades entirely (such as from dropping a backpack or other gear that was holding our grenades, while one is out)
if (count _currentThrowable < 1 || {_currentThrowable select 0 == ""}) exitWith {
    [_unit, "No valid throwables"] call FUNC(exitThrowMode);
};

private _currentGrenade = getText (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "ammo");
private _currentGrenadeMagazineType = _currentThrowable select 0;
GVAR(CurrentThrowSpeed) = getNumber (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "initSpeed");

if ([_unit] call FUNC(canThrow)) then {
    // These magazine checks are potentially not needed, but maaaaaybe would become relevant in some situations, like someone taking a grenade from your pack if you were holding it.
    if (GVAR(LastGrenadeTypeChecked) == "") then {
        GVAR(ActiveGrenadeType) = _currentGrenade;

        if (_currentGrenadeMagazineType in (magazines _unit)) then {
            GVAR(ActiveGrenadeItem) = _currentGrenade createVehicleLocal ((vehicle _unit) modelToWorldVisual [0, 0.3, 1.6]);
            if (GVAR(ActiveGrenadeType) == "") exitWith {
                GVAR(GrenadeInHand) = false;
            };
            GVAR(ActiveGrenadeItem) enableSimulation false;
        } else {
            _exit = true;
        };
    };

    if (_exit) exitWith {
        [_unit, "Trying to create a grenade we do not have in inventory (1)"] call FUNC(exitThrowMode);
    };

    if (GVAR(LastGrenadeTypeChecked) != _currentGrenade) then {
        deleteVehicle GVAR(ActiveGrenadeItem);
        GVAR(ActiveGrenadeType) = _currentGrenade;
        if (_currentGrenadeMagazineType in (magazines _unit)) then {
            GVAR(ActiveGrenadeItem) = _currentGrenade createVehicleLocal ((vehicle _unit) modelToWorldVisual [0, 0.3, 1.6]);
            if (GVAR(ActiveGrenadeType) == "") exitWith {
                GVAR(GrenadeInHand) = false;
            };
            GVAR(CurrentThrowSpeed) = getNumber (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "initSpeed");
            GVAR(ActiveGrenadeItem) enableSimulation false;
        } else {
            _exit = true
        };
    };

    if (_exit) exitWith {
        [_unit, "Trying to create a grenade we do not have in inventory (2)"] call FUNC(exitThrowMode);
    };
} else {
    if (!isNull GVAR(ActiveGrenadeItem)) then {
        GVAR(LastGrenadeTypeChecked) = "";
        deleteVehicle GVAR(ActiveGrenadeItem);
    };
    _exit = true;
};

if (_exit) exitWith {};

if (isNull GVAR(ActiveGrenadeItem)) exitWith {
    [_unit, "Cook drop"] call FUNC(exitThrowMode);
};


private _leanCoef = (_unit selectionPosition "head") select 0;
_leanCoef = _leanCoef - 0.15; // Counter the base offset
if (abs _leanCoef < 0.15 || {vehicle _unit != _unit}) then {
    _leanCoef = 0;
};

private _cameraOffset = [_leanCoef, 0, 0.3];
private _xAdjustBonus = [0, -0.075] select (GVAR(ThrowType) == "high");
private _yAdjustBonus = [0, 0.1] select (GVAR(ThrowType) == "high");

_cameraOffset = _cameraOffset vectorAdd CAMERA_ADJUST vectorAdd [_xAdjustBonus, _yAdjustBonus, 0];
private _posFin = (eyePos _unit) vectorAdd (positionCameraToWorld _cameraOffset) vectorDiff (positionCameraToWorld [0, 0, 0]);

GVAR(ActiveGrenadeItem) setVectorDir (vectorDirVisual _unit);
GVAR(ActiveGrenadeItem) setDir ((getDir _unit) + 90);

private _pitch = [-30, -90] select (GVAR(ThrowType) == "high");
[GVAR(ActiveGrenadeItem), _pitch, 0] call BIS_fnc_setPitchBank;


if (GVAR(CtrlHeld)) then {
    _posFin = (eyePos _unit) vectorAdd (positionCameraToWorld [_leanCoef, 0, GVAR(ExtArmCoef)]) vectorDiff (positionCameraToWorld [0, 0, 0]);
    private _posView = AGLtoASL (positionCameraToWorld [0, 0, 0]);

    if (lineIntersects [_posView, _posFin]) then {
        GVAR(ExtArmCoef) = GVAR(ExtArmCoef) - 0.10;
        if (GVAR(ExtArmCoef) < 0.2) then {
            GVAR(ExtArmCoef) = 0.2
        };
    };

    GVAR(ActiveGrenadeItem) setPosASL _posFin;
} else {
    if (vehicle _unit == _unit) then {
        GVAR(ActiveGrenadeItem) setPosASL _posFin;
    } else {
        private _vectorDiff = (velocity (vehicle _unit)) vectorMultiply (time - GVAR(LastTickTime));
        GVAR(ActiveGrenadeItem) setPosASL (_posFin vectorAdd _vectorDiff);
    };
};

GVAR(LastTickTime) = time;
GVAR(LastGrenadeTypeChecked) = GVAR(ActiveGrenadeType);
