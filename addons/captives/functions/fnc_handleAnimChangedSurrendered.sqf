/*
 * Author: Nic547, commy2
 * Restart the surrendering animation if it got interrupted. Called from a AnimChanged EH.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: New animation <STRING>
 *
 * ReturnValue:
 * None
 *
 * Public: No
 */


#include "script_component.hpp"

params ["_unit", "_newAnimation"];

TRACE_2("AnimChanged",_unit,_newAnimation);
if ((_newAnimation != "ACE_AmovPercMstpSsurWnonDnon") && {!(_unit getVariable ["ACE_isUnconscious", false])}) then {
    TRACE_1("Surrender animation interrupted",_newAnimation);
    [_unit, "ACE_AmovPercMstpSsurWnonDnon", 1] call EFUNC(common,doAnimation);
};
