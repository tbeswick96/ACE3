/*
 * Author: Dslyecxi, Jonpas
 * Handle all the changes.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_pfh
 *
 * Public: No
 */
#include "script_component.hpp"

if (!GVAR(Enable)) exitWith {
    [_this select 1] call CBA_fnc_removePerFrameHandler;
};

if (dialog) exitWith {
    if (GVAR(GrenadeInHand)) then {
        ["In dialog"] call FUNC(exitThrowMode);
    };
};


if (GVAR(GrenadeInHand) && {alive player}) then {
    private _exit = false;

    if (!(call FUNC(isFFVAndWeaponUp))) exitWith {
        ["In FFV and put weapon down"] call FUNC(exitThrowMode);
    };

    private _currentThrowable = currentThrowable player;

    // These handle if we run out of grenades entirely (such as from dropping a backpack or other gear that was holding our grenades, while one is out)
    if (count _currentThrowable < 1) exitWith {
        ["No valid throwables"] call FUNC(exitThrowMode);
    };
    if (_currentThrowable select 0 == "") exitWith {
        ["No valid throwables (check 2)"] call FUNC(exitThrowMode);
    };

    if (cameraView != "INTERNAL") exitWith {
        ["Went into sighted mode"] call FUNC(exitThrowMode);
    };

    //@todo: Check to see if we have a grenade like that in our inventory still

    private _currentGrenade = getText (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "ammo");
    private _currentGrenadeMagazineType = _currentThrowable select 0;
    GVAR(CurrentThrowSpeed) = getNumber (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "initSpeed");

    if (isNil QGVAR(CurrentThrowSpeed)) then {
        GVAR(CurrentThrowSpeed) = 0
    };

    // These magazine checks are potentially not needed, but maaaaaybe would become relevant in some situations, like someone taking a grenade from your pack if you were holding it.
    if (GVAR(LastGrenadeTypeChecked) == "") then {
        GVAR(ActiveGrenadeType) = _currentGrenade;

        if (_currentGrenadeMagazineType in (magazines player)) then {
            GVAR(ActiveGrenadeItem) = _currentGrenade createVehicleLocal ((vehicle player) modelToWorldVisual [0,.3,1.6]);
            if (GVAR(ActiveGrenadeType) == "") exitWith {
                GVAR(CancelThrow) = false;
                GVAR(GrenadeInHand) = false;
            };
            GVAR(ActiveGrenadeItem) enableSimulation false;
        } else {
            _exit = true;
        };
    };

    if (_exit) exitWith {
        ["Trying to create a grenade we do not have in inventory (1)"] call FUNC(exitThrowMode);
    };

    if (GVAR(LastGrenadeTypeChecked) != _currentGrenade) then {
        deleteVehicle GVAR(ActiveGrenadeItem);
        GVAR(ActiveGrenadeType) = _currentGrenade;
        if (_currentGrenadeMagazineType in (magazines player)) then {
            GVAR(ActiveGrenadeItem) = _currentGrenade createVehicleLocal ((vehicle player) modelToWorldVisual [0, 0.3, 1.6]);
            if (GVAR(ActiveGrenadeType) == "") exitWith {
                GVAR(CancelThrow) = false;
                GVAR(GrenadeInHand) = false
            };
            GVAR(CurrentThrowSpeed) = getNumber (configFile >> "CfgMagazines" >> _currentThrowable select 0 >> "initSpeed");
            GVAR(ActiveGrenadeItem) enableSimulation false;
        } else {
            _exit = true
        };
    };

    if (_exit) exitWith {
        ["Trying to create a grenade we do not have in inventory (2)"] call FUNC(exitThrowMode);
    };

    GVAR(CameraOffset) = [0, 0, 0.3];
    private _posLeftOffset = 0;
    private _posRightOffset = 0;

    if (inputAction "leanLeft" > 0.1) then {
        _posLeftOffset = linearConversion [0, 1, inputAction "leanLeft", 0, 0.25, true];
        GVAR(CameraOffset) = [-_posLeftOffset, 0, 0.3];
    };
    if (inputAction "leanRight" > 0.1) then {
        _posRightOffset = linearConversion [0, 1, inputAction "leanRight", 0, 0.25, true];
        GVAR(CameraOffset) = [_posRightOffset, 0, 0.3];
    };

    private _xAdjustBonus = 0;
    private _yAdjustBonus = 0;
    if (GVAR(ThrowType) == "under") then {
        _xAdjustBonus = -0.075;
        _yAdjustBonus = 0.1;
    };

    GVAR(CameraOffset) = GVAR(CameraOffset) vectorAdd GVAR(Adjust) vectorAdd [_xAdjustBonus, _yAdjustBonus, 0];

    private _posFin = AGLtoASL (positionCameraToWorld GVAR(CameraOffset));

    // Duplicate code
    private _vup = [0, 1, 1];
    if (GVAR(ThrowType) == "under") then {
        _vup = [1, 0, 0];
    };

    GVAR(ActiveGrenadeItem) setVectorUp _vup;
    GVAR(ActiveGrenadeItem) setVectorDir (vectorDirVisual player);

    GVAR(ActiveGrenadeItem) setDir ((getDir player) + 90);
    [GVAR(ActiveGrenadeItem), -30, 0] call BIS_fnc_setPitchBank;

    if (GVAR(ThrowType) == "under") then {
        [GVAR(ActiveGrenadeItem), -90, 0] call BIS_fnc_setPitchBank;
    };

    if (GVAR(CtrlHeld)) then {
        if (vehicle player == player) then {
            _posFin = AGLtoASL (positionCameraToWorld [0, 0, GVAR(TestPercArm)]);

            private _posView = AGLtoASL (positionCameraToWorld [0, 0, 0]);

            if (lineIntersects [_posView, _posFin]) then {
                GVAR(TestPercArm) = GVAR(TestPercArm) - 0.10;
                if (GVAR(TestPercArm) < 0.2) then {
                    GVAR(TestPercArm) = 0.2
                };
            };

            GVAR(ActiveGrenadeItem) setPosASL _posFin;
        };
    } else {
        if (vehicle player == player) then {
            GVAR(ActiveGrenadeItem) setPosASL _posFin;
        } else {
            private _vectorDiff = (velocity (vehicle player)) vectorMultiply (time - GVAR(LastTickTime));
            GVAR(ActiveGrenadeItem) setPosASL (_posFin vectorAdd _vectorDiff);
        };
    };

    GVAR(LastTickTime) = time;
    GVAR(LastGrenadeTypeChecked) = GVAR(ActiveGrenadeType);
};
