#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Cycles to the next/previous target entry.
 * Saves current UI state, switches active target, loads new entry.
 *
 * Arguments:
 * 0: Direction (-1 = previous, +1 = next) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_direction"];

// Save current UI fields to active target
call FUNC(planner_saveTarget);

// Cycle with wrapping
if (_direction > 0) then {
    GVAR(activeTarget) = (GVAR(activeTarget) + 1) % MAX_CRUISE_TARGETS;
} else {
    GVAR(activeTarget) = GVAR(activeTarget) - 1;
    if (GVAR(activeTarget) < 0) then {
        GVAR(activeTarget) = MAX_CRUISE_TARGETS - 1;
    };
};

// Load new target into UI
call FUNC(planner_loadTarget);

TRACE_1("planner_cycleTarget",GVAR(activeTarget));
