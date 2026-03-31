#include "script_component.hpp"

if (!hasInterface) exitWith {};

["ace_settingsInitialized", {
    ["turret", LINKFUNC(setupVehicle), false] call CBA_fnc_addPlayerEventHandler;
    ["vehicle", LINKFUNC(setupVehicle), true] call CBA_fnc_addPlayerEventHandler;
}] call CBA_fnc_addEventHandler;
