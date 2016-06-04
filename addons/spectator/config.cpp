#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"F3 Project","Head","SilentSpike","voiper"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "ACE_Settings.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "ui\interface.hpp"

class CfgRespawnTemplates {
    class ADDON {
        onPlayerKilled = QFUNC(respawnTemplate);
        onPlayerRespawn = QFUNC(respawnTemplate);
    };
};
