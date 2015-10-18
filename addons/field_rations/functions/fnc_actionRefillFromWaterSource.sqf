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

params ["_dummyTarget", "_player", "_itemClassname"];

// Prepare all info necessary for completing the action
local _onRefillItem = getText (configFile >> "CfgWeapons" >> _itemClassname >> QGVAR(onRefill));
if (_onRefillItem == "") exitwith {}; // TODO add logging of invalid state

local _progressBarText = "Refilling"; // TODO localization of the progress bar text
local _onFinish = {
    systemChat format ["_onFinish %1", _this];
    EXPLODE_4_PVT((_this select 0),_dummyTarget,_player,_itemClassname,_onRefillItem);

    // Switch out the old item by the newly refilled item
    _player removeItem _itemClassname;
    _player addItem _onRefillItem;
};

local _onFailure = {
    systemChat format ["Fail %1", _this];
};

[6, [_dummyTarget,_player,_itemClassname,_onRefillItem], _onFinish, _onFailure, _progressBarText, {(_this select 0) call FUNC(canRefillFromWaterSource)}] call EFUNC(common,progressBar);
