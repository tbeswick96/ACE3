#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

GVAR(headlessClients) = [];

if (isServer) then {
    GVAR(inRebalance) = false;
    GVAR(endMissionCheckDelayed) = false;
    [QXGVAR(headlessClientJoined), LINKFUNC(handleConnectHC)] call CBA_fnc_addEventHandler;
};

ADDON = true;
