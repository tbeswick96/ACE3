/*
 * Author: PabstMirror
 * Checks the conditions for being able to disarm a unit
 *
 * Arguments:
 * 0: Target <OBJECT>
 *
 * Return Value:
 * Can Be Disarmed <BOOL>
 *
 * Example:
 * [cursorTarget] call ace_disarming_fnc_canBeDisarmed
 *
 * Public: No
 */
#include "script_component.hpp"

#define DEFAULT_ALPHA_LEVEL 0.6

DEFAULT_PARAM(0,_transistionTime,10);

disableSerialization;
local _playerStatusUI = uiNamespace getVariable ["ace_field_rations_PlayerStatusUI", displayNull];

local _drinkStatus = ACE_player getVariable [QGVAR(thirstStatus), 100];
local _foodStatus = ACE_player getVariable [QGVAR(hungerStatus), 100];
local _hudForceShow = ((_drinkStatus < 30) || {_foodStatus < 30});

if ((!isNull ACE_player) && {alive ACE_player} && {_hudForceShow || GVAR(hudInteractionHover)}) then {
    if ((!GVAR(hudIsShowing)) || {isNull _playerStatusUI}) then {
        GVAR(hudIsShowing) = true;
        ("ace_field_rations_PlayerStatusUI" call BIS_fnc_rscLayer) cutRsc ["ace_field_rations_PlayerStatusUI", "PLAIN", _transistionTime, false];
    };

    local _playerStatusUI = uiNamespace getVariable ["ace_field_rations_PlayerStatusUI", displayNull];

    local _greenFood = _foodStatus/100;
    local _redFood = 1.0 - _greenFood;
    local _yellowFood = 0;
    (_playerStatusUI displayCtrl 11112) ctrlSetTextColor [_redFood, _greenFood, _yellowFood, DEFAULT_ALPHA_LEVEL];

    local _greenDrink = _drinkStatus/100;
    local _redDrink = 1.0 - _greenDrink;
    local _yellowDrink = 0;
    (_playerStatusUI displayCtrl 11113) ctrlSetTextColor [_redDrink, _greenDrink, _yellowDrink, DEFAULT_ALPHA_LEVEL];
} else {
    if (GVAR(hudIsShowing)) then {
        GVAR(hudIsShowing) = false;
        ("ace_field_rations_PlayerStatusUI" call BIS_fnc_rscLayer) cutFadeOut 5;
    };
};
