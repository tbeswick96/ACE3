/*
 * Author: Jonpas
 * Sets advanced visible element of the UI using displays and controls.
 *
 * Arguments:
 * 0: Element Name <STRING>
 * 1: Show/Hide Element <BOOL>
 * 2: Show Hint <BOOL>
 * 3: Force change even when disallowed <BOOL> (default: false)
 *
 * Return Value:
 * Successfully Set <BOOL>
 *
 * Example:
 * _successfullySet = ["ammoCount", true, false] call ace_ui_fnc_setAdvancedElement
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_element", "_show", ["_showHint", false, [true]], ["_force", false, [true]] ];

private _cachedElement = GVAR(configCache) getVariable _element;
if (isNil "_cachedElement") exitWith {};

if (!_force && {!GVAR(allowSelectiveUI)}) exitWith {
    [LSTRING(Disallowed), 2] call EFUNC(common,displayTextStructured);
    false
};

_cachedElement params ["_idd", "_elements", "_location", "_conditions"];

// Exit if main vehicle type condition not fitting
private _canUseWeapon = ACE_player call CBA_fnc_canUseWeapon;
if ((_canUseWeapon && {_location == 2}) || {!_canUseWeapon && {_location == 1}}) exitWith {false};

// Get setting from config API
{
    if (!call (_x select 0)) exitWith {
        // Display and print info which component forced the element except for default vehicle check
        if (_showHint) then {
            [LSTRING(Disabled), 2] call EFUNC(common,displayTextStructured);
            ACE_LOGINFO_2("Attempted modification of a forced User Interface element '%1' by '%2'.",_element,_x select 1);
        };
        _show = false;
    };
} count _conditions;

// Get setting from scripted API
if (!_force) then {
    private _setElement = GVAR(elementsSet) getVariable _element;
    if (!isNil "_setElement") then {
        _setElement params ["_sourceSet", "_showSet"];
        if (_showHint) then {
            [LSTRING(Disabled), 2] call EFUNC(common,displayTextStructured);
            ACE_LOGINFO_2("Attempted modification of a forced User Interface element '%1' by '%2'.",_element,_sourceSet);
        };
        _show = _showSet;
    };
};

_show = [1, 0] select _show;

// Disable/Enable elements
private _success = false;
{
    private _idc = _x;

    // Loop through IGUI displays as they can be present several times for some reason
    {
        if (_idd == ctrlIDD _x) then {
            //TRACE_3("Setting Element Visibility",_show,_idd,_idc);

            (_x displayCtrl _idc) ctrlSetFade _show;
            (_x displayCtrl _idc) ctrlCommit 0;

            _success = true;
        };
    } count (uiNamespace getVariable "IGUI_displays");
    nil
} count _elements;

_success
