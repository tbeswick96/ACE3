#include "script_component.hpp"

// Exit on HC
if (!hasInterface) exitWith {};


// Enable/disable
["SettingsInitialized", {
    if (GVAR(Enabled)) then {
        [true] call FUNC(init);
    };
}] call EFUNC(common,addEventHandler);

["SettingChanged", {
    params ["_name", "_value"];
    if (_name == QGVAR(Enabled)) then  {
        [_value] call FUNC(init);
    };
}] call EFUNC(common,addEventHandler);


// Add keybinds
["ACE3 Weapons", QGVAR(PrepareGrenade), localize LSTRING(PrepareGrenade), {
    // Condition
    if (!([ACE_player] call FUNC(canPrepareGrenade))) exitWith {false};

    // Statement
    [ACE_player] call FUNC(prepareGrenade);
},
{false},
[34, [true, false, false]], false] call CBA_fnc_addKeybind; // Shift + G


// Event handlers
["playerChanged", {
    [_this select 1, "Player changed"] call FUNC(exitThrowMode);
}] call EFUNC(common,addEventhandler);
