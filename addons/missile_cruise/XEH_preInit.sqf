#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(weapons) = createHashMap;
GVAR(activeTarget) = 0;
GVAR(targetSettings) = createHashMap;
for "_i" from 0 to (MAX_CRUISE_TARGETS - 1) do {
    GVAR(targetSettings) set [_i, createHashMapFromArray [
        ["position", [0, 0, 0]],
        ["impactAngle", -1],
        ["attackHeading", -1],
        ["height", 0],
        ["cruiseAltitude", 100],
        ["waypoints", []]
    ]];
};

ADDON = true;
