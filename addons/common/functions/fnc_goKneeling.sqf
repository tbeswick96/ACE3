/*
 * Author: commy2
 * Move unit to kneeling position (only if not yet prone).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

// Animation changes even inside vehicle post-1.60
if (stance _unit == "PRONE" || {vehicle ACE_player != ACE_player}) exitWith {};

[
    _unit,
    ["AmovPknlMstpSnonWnonDnon", "AmovPknlMstpSlowWrflDnon", "AmovPknlMstpSrasWlnrDnon", "AmovPknlMstpSlowWpstDnon", "AmovPknlMstpSoptWbinDnon"] select ((["", primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit, binocular _unit] find currentWeapon _unit) max 0)
] call FUNC(doAnimation);
