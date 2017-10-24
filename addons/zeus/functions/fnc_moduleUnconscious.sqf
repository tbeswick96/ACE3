/*
 * Author: SilentSpike
 * Flips the unconscious state of the unit the module is placed on.
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 * 1: Synchronized units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [LOGIC, [bob, kevin], true] call ace_zeus_fnc_moduleUnconscious
 *
 * Public: No
 */

#include "script_component.hpp"

params ["_logic", "_units", "_activated"];

if !(_activated && local _logic) exitWith {};

if (isNil QEFUNC(medical,setUnconscious)) then {
    [LSTRING(RequiresAddon)] call FUNC(showMessage);
} else {
    private _mouseOver = GETMVAR(bis_fnc_curatorObjectPlaced_mouseOver,[""]);

    if ((_mouseOver select 0) != "OBJECT") then {
        [LSTRING(NothingSelected)] call FUNC(showMessage);
    } else {
        private _unit = effectivecommander (_mouseOver select 1);

        if !(_unit isKindOf "CAManBase") then {
            [LSTRING(OnlyInfantry)] call FUNC(showMessage);
        } else {
            if !(alive _unit) then {
                [LSTRING(OnlyAlive)] call FUNC(showMessage);
            } else {
                private _conscious = GETVAR(_unit,ACE_isUnconscious,false);
                // Function handles locality for me
                [_unit, !_conscious, 10e10, true] call EFUNC(medical,setUnconscious);
            };
        };
    };
};

deleteVehicle _logic;
