/*
 * Author: PabstMirror
 * Eats/Drinks an item
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Item Classname <String>
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

PARAMS_3(_target,_player,_itemClassname);

_cfg = ConfigFile >> "CfgWeapons" >> _itemClassname;

local _consumeTime = getNumber (_cfg >> QGVAR(consumeTime));
local _displayName = getText (_cfg >> "displayName");
local _hungerRestored = getNumber (_cfg >> QGVAR(isEatable));
local _thirstRestored = getNumber (_cfg >> QGVAR(isDrinkable));
local _replacementItem = getText (_cfg >> QGVAR(replacementItem));

local _progressBarText = if (_thirstRestored > 0) then {
    format ["Drinking %1", _displayName];
} else {
    format ["Eating %1", _displayName];
};

local _onFinish = {
    systemChat format ["_onFinish %1", _this];
    EXPLODE_6_PVT((_this select 0),_target,_player,_itemClassname,_hungerRestored,_thirstRestored,_replacementItem);

    _player removeItem _itemClassname;
    if (_hungerRestored > 0) then {
        local _currentLevel = _unit getvariable [QGVAR(thirstStatus), 100];
        _player setvariable [QGVAR(thirstStatus), ((_currentLevel + _hungerRestored) min 100)];
    };
    if (_thirstRestored > 0) then {
        local _currentLevel = _unit getvariable [QGVAR(hungerStatus), 100];
        _player setvariable [QGVAR(hungerStatus), ((_currentLevel + _thirstRestored) min 100)];
    };
};

local _onFailure = {
    systemChat format ["Fail %1", _this];
};

[_consumeTime, [_target, _player, _itemClassname, _hungerRestored, _thirstRestored, _replacementItem], _onFinish, _onFailure, _progressBarText, {(_this select 0) call FUNC(canConsumeItem)}] call EFUNC(common,progressBar);
