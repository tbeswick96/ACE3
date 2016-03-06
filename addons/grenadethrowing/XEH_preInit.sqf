#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

GVAR(GrenadeInHand) = false;
GVAR(ToggleThrowMode) = false;
GVAR(CookingGrenade) = false;

GVAR(ActiveGrenadeItem) = objNull;
GVAR(ActiveGrenadeType) = "";

GVAR(ThrowType) = "normal";
GVAR(CurrentThrowSpeed) = 18;
GVAR(ExtArmCoef) = 0.2;

GVAR(LastGrenadeTypeChecked) = "";
GVAR(DropCookedCounter) = 0;
GVAR(LastTickTime) = 0;

ADDON = true;
