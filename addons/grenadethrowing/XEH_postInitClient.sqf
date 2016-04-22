#include "script_component.hpp"

// Exit on HC
if (!hasInterface) exitWith {};


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

[QGVAR(throwFiredXEH), {_this call FUNC(throwFiredXEH)}] call EFUNC(common,addEventHandler);


// Display handlers
["KeyDown", {_this call FUNC(onKeyDown)}] call CBA_fnc_addDisplayHandler;
["KeyUp", {_this call FUNC(onKeyUp)}] call CBA_fnc_addDisplayHandler;
["MouseButtonDown", {_this call FUNC(onMouseButtonDown)}] call CBA_fnc_addDisplayHandler;
["MouseZChanged", {_this call FUNC(onMouseScroll)}] call CBA_fnc_addDisplayHandler;
