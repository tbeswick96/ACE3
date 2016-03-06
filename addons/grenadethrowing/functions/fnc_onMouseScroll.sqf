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

if (!GVAR(Enabled) || {!GVAR(GrenadeInHand)} || {dialog}) exitWith {};

params ["", "_amount"];

if (GVAR(CtrlHeld)) then {
    // Extended arm dropping
    if (_amount < 0) then {
        TRACE_1("Move Closer",_amount);
        GVAR(ExtArmCoef) = GVAR(ExtArmCoef) - 0.1;
        if (GVAR(ExtArmCoef) < 0.2) then {
            GVAR(ExtArmCoef) = 0.2
        };
    } else {
        TRACE_1("Move Further",_amount);
        GVAR(ExtArmCoef) = GVAR(ExtArmCoef) + 0.1;
        if (GVAR(ExtArmCoef) > 1) then {
            GVAR(ExtArmCoef) = 1
        };
    };
} else {
    if (_amount < 0) then {
        if (GVAR(ThrowType) == "high") then {
            GVAR(ThrowType) = "normal";
        };
    } else {
        if (GVAR(ThrowType) == "normal") then {
            GVAR(ThrowType) = "high";
        };
    };
    TRACE_2("Change Throw Type",_amount,GVAR(ThrowType));
};
