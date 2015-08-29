#include "script_component.hpp"

if !(hasInterface) exitWith {};

GVAR(hudInteractionHover) = false;
GVAR(hudIsShowing) = false;

["SettingsInitialized", {
    //If not enabled, dont't add PFEH or actions
    if (!GVAR(systemEnabled)) exitWith {};
    if ((GVAR(timeWithoutWater) == 0) || {GVAR(timeWithoutFood) == 0}) exitWith {
        ERROR("Bad Time Setting [div/0]");
    };

    [] call FUNC(addRefillActionsToObjects);

    [{_this call DFUNC(updateFieldRations)}, 10, [ACE_time, (ACE_time + 60)]] call CBA_fnc_addPerFrameHandler;

    ["interactMenuClosed", {
        if (GVAR(hudInteractionHover)) then {
            GVAR(hudInteractionHover) = false;
            [] call FUNC(showOverlay);
        };
    }] call EFUNC(common,addEventHandler);

}] call EFUNC(common,addEventHandler);
