#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common", "ace_missileguidance", "ace_interact_menu"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"UKSF"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

class RscText;
class RscEdit;
class RscButton;
class RscCombo;

#include "ACE_GuidanceConfig.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgMissileTypesNato.hpp"
#include "CruisePlannerDialog.hpp"
