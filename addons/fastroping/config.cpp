#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_interaction"};
        author[] = {"KoffeinFlummi", "BaerMitUmlaut"};
        authorUrl = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgMoves.hpp"
#include "CfgSounds.hpp"
#include "CfgVehicles.hpp"
#include "CfgWaypoints.hpp"
