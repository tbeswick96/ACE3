#include "script_component.hpp"

// Exit on HC
if (!hasInterface) exitWith {};


["SettingsInitialized", {
    if (GVAR(Enabled)) then {
        [true] call FUNC(init);
    };

    ["SettingChanged", {
        params ["_name", "_value"];

        if !(_name == QGVAR(Enabled)) exitWith  {};

        if (_value) then {
            [true] call FUNC(init);
        } else {
            [false] call FUNC(init);
        };
    }] call EFUNC(common,addEventHandler);
}] call EFUNC(common,addEventHandler);
