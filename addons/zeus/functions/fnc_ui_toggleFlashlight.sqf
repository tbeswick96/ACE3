/*
 * Author: alganthe
 * Initalises the `Toggle Flashlights` zeus module display
 *
 * Arguments:
 * 0: Flashlight toggle controls group <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * onSetFocus = "_this call ace_zeus_fnc_ui_toggleFLashlight"
 *
 * Public: No
*/

#include "script_component.hpp"

disableSerialization;

params ["_control"];

//Generic Init:
private _display = ctrlparent _control;
private _ctrlButtonOK = _display displayctrl 1; //IDC_OK
private _logic = GETMVAR(BIS_fnc_initCuratorAttributes_target,objnull);
TRACE_1("logicObject",_logic);

_control ctrlRemoveAllEventHandlers "setFocus";

private _unit = effectiveCommander (attachedTo _logic);

// Handles errors
scopeName "Main";
private _fnc_errorAndClose = {
    params ["_msg"];
    _display closeDisplay 0;
    deleteVehicle _logic;
    [_msg] call FUNC(showMessage);
    breakOut "Main";
};

if !(isNull _unit) then {
    switch (false) do {
        case (_unit isKindOf "CAManBase"): {
            [LSTRING(OnlyInfantry)] call _fnc_errorAndClose;
        };
        case (alive _unit): {
            [LSTRING(OnlyAlive)] call _fnc_errorAndClose;
        };
    };
};

//Specific on-load stuff:
private _comboBox = _display displayCtrl 56218;
private _comboBox2 = _display displayCtrl 56219;
private _comboBox3 = _display displayCtrl 56220;

{
    _comboBox lbSetValue  [_comboBox lbAdd (_x select 0), _x select 1];
} forEach [
    [localize ELSTRING(common,Disabled), 0],
    [localize ELSTRING(common,Enabled), 1]
];

if (isNull _unit) then {
    {
        _comboBox2 lbSetValue  [_comboBox2 lbAdd (_x select 0), _x select 1];
    } forEach [
        ["BLUFOR", 0],
        ["OPFOR", 1],
        ["INDEP", 2],
        ["CIV", 3]
    ];
} else {
    {
        _comboBox2 lbSetValue  [_comboBox2 lbAdd (_x select 0), _x select 1];
    } forEach [
        [localize LSTRING(moduleToggleNVG_SelectedGroup), 4],
        ["BLUFOR", 0],
        ["OPFOR", 1],
        ["INDEP", 2],
        ["CIV", 3]
    ];
};

{
    _comboBox3 lbSetValue  [_comboBox3 lbAdd (_x select 0), _x select 1];
} foreach [
    [localize ELSTRING(common,Disabled), 0],
    [localize ELSTRING(common,Enabled), 1]
];


private _enabledDefault = false;
if (!isNull _unit) then {
    _enabledDefault = _unit isFlashlightOn (currentWeapon _unit);
};
_comboBox lbSetCurSel ([0,1] select _enabledDefault);
_comboBox2 lbSetCurSel 0;
_comboBox3 lbSetCurSel 0;

private _fnc_onUnload = {
    params ["_display"];

    private _logic = GETMVAR(BIS_fnc_initCuratorAttributes_target,objnull);
    if (isNull _logic) exitWith {};

    deleteVehicle _logic;
};

private _fnc_onConfirm = {
    params [["_ctrlButtonOK", controlNull, [controlNull]]];

    private _display = ctrlparent _ctrlButtonOK;
    if (isNull _display) exitWith {};

    private _logic = GETMVAR(BIS_fnc_initCuratorAttributes_target,objnull);
    if (isNull _logic) exitWith {};

    private _combo1 = _display displayCtrl 56218;
    private _combo2 = _display displayCtrl 56219;
    private _combo3 = _display displayCtrl 56220;

    private _toggle = _combo1 lbValue (lbCurSel _combo1);
    private _target = _combo2 lbValue (lbCurSel _combo2);
    private _gear = _combo3 lbValue (lbCurSel _combo3);

    [_logic, _toggle == 1, _gear == 1, _target] call FUNC(moduleToggleFlashlight);
};

_display displayAddEventHandler ["unload", _fnc_onUnload];
_ctrlButtonOK ctrlAddEventHandler ["buttonclick", _fnc_onConfirm];
