/*
 * Author: Dslyecxi, Jonpas
 * Mouse scroll wheel changed event.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_grenadethrowing_fnc_onMouseScroll
 *
 * Public: No
 */
#include "script_component.hpp"

if (dialog) exitWith {};

params ["", "_amount"];

if (GVAR(CtrlHeld)) then {
    // If we want to do FUNKY MAGIC
    if (_amount < 0 && {GVAR(GrenadeInHand)}) then {
        GVAR(TestPercArm) = GVAR(TestPercArm) - 0.1;
        if (GVAR(TestPercArm) < 0.2) then {
            GVAR(TestPercArm) = 0.2
        };
    } else {
        GVAR(TestPercArm) = GVAR(TestPercArm) + 0.1;
        if (GVAR(TestPercArm) > 1) then {
            GVAR(TestPercArm) = 1
        };
    };
} else {
    if (_amount < 0 && {GVAR(GrenadeInHand)}) then {
        TRACE_1("Cancel Throw",_amount,GVAR(GrenadeInHand));

        if (GVAR(CookingGrenade)) then {
            GVAR(DropCookedCounter) = GVAR(DropCookedCounter) + 1;

            if (GVAR(DropCookedCounter) >= 3) then {
                ["Dropping cooked grenade"] call FUNC(exitThrowMode);
                GVAR(DropCookedCounter) = 0;
            };
        } else {
            ["Storing grenade without throwing"] call FUNC(exitThrowMode);
        };
    };

    if (_amount > 0 && {GVAR(GrenadeInHand)}) then {
        if (GVAR(ThrowType) == "normal") then {
            GVAR(ThrowType) = "under";
        } else {
            if (GVAR(ThrowType) == "under") then {
                GVAR(ThrowType) = "normal";
            };
        };
    };
};
