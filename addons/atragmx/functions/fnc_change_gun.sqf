/*
 * Author: Ruthberg
 * Selects a new gun profile and updates the gun column and the result input/output fields
 *
 * Arguments:
 * gunID <number>
 * restore workingMemory from gunList <BOOL>
 * update display <BOOL>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ace_atragmx_fnc_change_gun
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_gunID", "_restoreMemory", "_updateDisplay"];

if (_gunID < 0 || _gunID > (count GVAR(gunList)) - 1) exitWith {};

if (_restoreMemory) then {
    GVAR(workingMemory) = +(GVAR(gunList) select _gunID);
};
GVAR(currentGun) = _gunID;

if (_updateDisplay) then {
    lbSetCurSel [6000, GVAR(currentGun)];
};

GVAR(currentScopeUnit) = 0 max (GVAR(workingMemory) select 6) min 3;
GVAR(currentScopeClickUnit) = 0 max (GVAR(workingMemory) select 7) min 2;
GVAR(currentScopeClickNumber) = 1 max (GVAR(workingMemory) select 8) min 10;

if (_updateDisplay) then {
    [] call FUNC(update_gun);
    [] call FUNC(update_gun_ammo_data);
};

GVAR(elevationOutput) set [GVAR(currentTarget), 0];
GVAR(windage1Output) set [GVAR(currentTarget), 0];
GVAR(windage2Output) set [GVAR(currentTarget), 0];
GVAR(leadOutput) set [GVAR(currentTarget), 0];
GVAR(tofOutput) set [GVAR(currentTarget), 0];
GVAR(velocityOutput) set [GVAR(currentTarget), 0];

if (_updateDisplay) then {
    [] call FUNC(calculate_target_solution);
};
