/*
 * Author: PabstMirror
 * Checks the conditions for being able to disarm a unit
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Item Classname <STRING>
 *
 * Return Value:
 * Can Be Refilled <BOOL>
 *
 * Example:
 * [barrel, player, "bottle"] call ace_disarming_fnc_canBeDisarmed
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_3(_dummyTarget,_player,_itemClassname);

_onRefillItem = getText (configFile >> "CfgWeapons" >> _itemClassname >> QGVAR(onRefill));

_progressBarText = "Refilling";

_onFinish = {
    systemChat format ["_onFinish %1", _this];
    EXPLODE_4_PVT((_this select 0),_dummyTarget,_player,_itemClassname,_onRefillItem);

    _player removeItem _itemClassname;
    _player addItem _onRefillItem;
};

_onFailure = {
    systemChat format ["Fail %1", _this];
};

[6, [_dummyTarget,_player,_itemClassname,_onRefillItem], _onFinish, _onFailure, _progressBarText, {(_this select 0) call FUNC(canRefillFromWaterSource)}] call EFUNC(common,progressBar);
