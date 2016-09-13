/*
 * Author: Glowbal
 * Start unload action.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_cargo_fnc_startUnload
 *
 * Public: No
 */
#include "script_component.hpp"

disableSerialization;

private _display = uiNamespace getVariable QGVAR(menuDisplay);
if (isNil "_display") exitWith {};

private _loaded = GVAR(interactionVehicle) getVariable [QGVAR(loaded), []];
if (_loaded isEqualTo []) exitWith {};

private _ctrl = _display displayCtrl 100;

private _selected = (lbCurSel _ctrl) max 0;

if (count _loaded <= _selected) exitWith {};
private _item = _loaded select _selected; //This can be an object or a classname string

if (GVAR(interactionParadrop)) exitWith {
    // Start progress bar - paradrop
    private _size = [_item] call FUNC(getSizeItem);
    [
        2.5 * _size,
        [_item, GVAR(interactionVehicle), ACE_player],
        {
            (_this select 0) params ["_item", "_target", "_player"];
            [QGVAR(paradropItem), [_item, _target]] call CBA_fnc_localEvent;
        },
        {
            params ["_args", "", "", "_errorCode"]; // show warning if we failed because of flight conditions
            if (_errorCode == 3) then {
                _args params ["_item", "_target", "_player"];
                [localize LSTRING(unlevelFlightWarning)] call EFUNC(common,displayTextStructured);
            };
        },
        localize LSTRING(UnloadingItem),
        {
            (_this select 0) params ["_item", "_target", "_player"];
            if ((acos ((vectorUp _target) select 2)) > 30) exitWith {false}; // check flight level
            if (((getPos _target) select 2) < 25) exitWith {false}; // check height
            if ((speed _target) < -5) exitWith {false}; // check reverse
            true
        },
        ["isNotSwimming", "isNotInside"]
    ] call EFUNC(common,progressBar);
};


// Start progress bar - normal ground unload
if ([_item, GVAR(interactionVehicle), ACE_player] call FUNC(canUnloadItem)) then {
    private _size = [_item] call FUNC(getSizeItem);

    [
        5 * _size,
        [_item, GVAR(interactionVehicle), ACE_player],
        {["ace_unloadCargo", _this select 0] call CBA_fnc_localEvent},
        {},
        localize LSTRING(UnloadingItem),
        {true},
        ["isNotSwimming"]
    ] call EFUNC(common,progressBar);
} else {
    private _itemClass = if (_item isEqualType "") then {_item} else {typeOf _item};
    private _displayName = getText (configFile >> "CfgVehicles" >> _itemClass >> "displayName");

    [[LSTRING(UnloadingFailed), _displayName], 3.0] call EFUNC(common,displayTextStructured);
};
