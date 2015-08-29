/*
 * Author: PabstMirror
 * Adds refill water actions to water sources
 * Needs to be done dynamicly as these objects may not exist depending on other mods (AiA/CUP TP)
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None <Nil>
 *
 * Example:
 * [] call ace_field_rations_fnc_addRefillActionsToObjects
 *
 * Public: No
 */
#include "script_component.hpp"

#define WATER_SOURCES [\
    ["Land_Barrel_water"],\
    ["Land_BarrelWater_F"],\
    ["Land_stand_waterl_EP1"],\
    ["Land_Reservoir_EP1"],\
    ["Land_Misc_Well_C_EP1"],\
    ["Land_Misc_Well_L_EP1"]]

_fncGetChildren = {
    _player = _this select 1;
    _actions = [];
    {
        _cfg = configFile >> "CfgWeapons" >> _x;
        if ((isClass _cfg) && {(getText (_cfg >> QGVAR(onRefill))) != ""}) then {
            _displayName = getText (_cfg >> "displayName");
            _picture = getText (_cfg >> "picture");
            _actionText = format ["RXefill %1", _displayName];
            _action = [_x, _actionText, _picture, {_this call FUNC(actionRefillFromWaterSource)}, {_this call FUNC(canRefillFromWaterSource)}, {}, _x] call EFUNC(interact_menu,createAction);
            _actions pushBack [_action, [], _player];
        };
    } forEach (items _player);
    _actions
};

_action = [QGVAR(refill), (localize LSTRING(refillWater)), QUOTE(PATHTOF(ui\hud_drinkstatus2.paa)), {}, {true}, _fncGetChildren, [], [0,0,0], 4] call EFUNC(interact_menu,createAction);

{
    EXPLODE_1_PVT(_x,_classname);
    _cfg = configFile >> "CfgVehicles" >> _classname;
    TRACE_2("Adding actions for object", _classname, (isClass _cfg));
    if (isClass _cfg) then {
        [_classname, 0, [], _action] call EFUNC(interact_menu,addActionToClass);
    };
} forEach WATER_SOURCES;
