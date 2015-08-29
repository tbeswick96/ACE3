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

_consumeTime = getNumber (_cfg >> QGVAR(consumeTime));
_displayName = getText (_cfg >> "displayName");
_hungerRestored = getNumber (_cfg >> QGVAR(isEatable));
_thirstRestored = getNumber (_cfg >> QGVAR(isDrinkable));
_replacementItem = getText (_cfg >> QGVAR(replacementItem));

_progressBarText = if (_thirstRestored > 0) then {
    format ["Drinking %1", _displayName];
} else {
    format ["Eating %1", _displayName];
};

_onFinish = {
    systemChat format ["_onFinish %1", _this];
    EXPLODE_6_PVT((_this select 0),_target,_player,_itemClassname,_hungerRestored,_thirstRestored,_replacementItem);

    _player removeItem _itemClassname;
    if (_hungerRestored > 0) then {
        _currentLevel = _unit getvariable [QGVAR(thirstStatus), 100];
        _player setvariable [QGVAR(thirstStatus), ((_currentLevel + _hungerRestored) min 100)];
    };
    if (_thirstRestored > 0) then {
        _currentLevel = _unit getvariable [QGVAR(hungerStatus), 100];
        _player setvariable [QGVAR(hungerStatus), ((_currentLevel + _thirstRestored) min 100)];
    };
};

_onFailure = {
    systemChat format ["Fail %1", _this];
};

[_consumeTime, [_target, _player, _itemClassname, _hungerRestored, _thirstRestored, _replacementItem], _onFinish, _onFailure, _progressBarText, {(_this select 0) call FUNC(canConsumeItem)}] call EFUNC(common,progressBar);
