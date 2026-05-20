#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(katLoaded) = isClass (configFile >> "CfgPatches" >> "kat_airway");

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
