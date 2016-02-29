#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

GVAR(GrenadeInHand) = false;
GVAR(CancelThrow) = false;
GVAR(ToggleThrowMode) = false;
GVAR(ThrowGrenade) = false;
GVAR(CookingGrenade) = false;

GVAR(ActiveGrenadeItem) = objNull;
GVAR(ActiveGrenadeType) = "";

GVAR(CameraOffset) = [0, 0, 0.3];
GVAR(zAdjust) = -0.03;
GVAR(xAdjust) = -0.05;
GVAR(yAdjust) = -0.12; // up down

GVAR(ThrowType) = "normal";
GVAR(ThrowStyle_Normal_Direction) = [0, 70, 500];
GVAR(CurrentThrowSpeed) = 18;
GVAR(ThrowStyle_Under_Direction) = [0, 200, 500];
GVAR(ThrowStyle_Under_Velocity) = 8;
GVAR(TestPercArm) = 0.2;

GVAR(LastGrenadeTypeChecked) = "";
GVAR(LastThrownTime) = 0;
GVAR(TimeBetweenThrows) = 2.25;
GVAR(DropCookedCounter) = 0;
GVAR(AmmoLastMag) = 3;
GVAR(LastTickTime) = 0;

GVAR(ExitInProgress) = false;
GVAR(CtrlHeld) = false;

ADDON = true;
