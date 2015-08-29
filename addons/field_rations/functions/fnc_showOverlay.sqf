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
_playerStatusUI = uiNamespace getVariable ["ace_field_rations_PlayerStatusUI", displayNull];

_drinkStatus = ACE_player getVariable [QGVAR(thirstStatus), 100];
_foodStatus = ACE_player getVariable [QGVAR(hungerStatus), 100];
_hudForceShow = ((_drinkStatus < 30) || {_foodStatus < 30});

if ((!isNull ACE_player) && {alive ACE_player} && {_hudForceShow || GVAR(hudInteractionHover)}) then {
    diag_log text format ["aaa Show"];
    if ((!GVAR(hudIsShowing)) || {isNull _playerStatusUI}) then {
        GVAR(hudIsShowing) = true;
        ("ace_field_rations_PlayerStatusUI" call BIS_fnc_rscLayer) cutRsc ["ace_field_rations_PlayerStatusUI", "PLAIN", _transistionTime, false];
    };

    _playerStatusUI = uiNamespace getVariable ["ace_field_rations_PlayerStatusUI", displayNull];

    _greenFood = _foodStatus/100;
    _redFood = 1.0 - _greenFood;
    _yellowFood = 0;
    (_playerStatusUI displayCtrl 11112) ctrlSetTextColor [_redFood,_greenFood,_yellowFood, DEFAULT_ALPHA_LEVEL];

    _greenDrink = _drinkStatus/100;
    _redDrink = 1.0 - _greenDrink;
    _yellowDrink = 0;
    (_playerStatusUI displayCtrl 11113) ctrlSetTextColor [_redDrink,_greenDrink,_yellowDrink, DEFAULT_ALPHA_LEVEL];
} else {
    diag_log text format ["aaa Hide"];
    if (GVAR(hudIsShowing)) then {
        GVAR(hudIsShowing) = false;
        ("ace_field_rations_PlayerStatusUI" call BIS_fnc_rscLayer) cutFadeOut 5;
    };
};
