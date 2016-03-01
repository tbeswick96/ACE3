#include "script_component.hpp"

// Exit on HC
if (!hasInterface) exitWith {};

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
