#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"KoffeinFlummi","commy2"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgAISkill.hpp"
#include "CfgWeapons.hpp"
