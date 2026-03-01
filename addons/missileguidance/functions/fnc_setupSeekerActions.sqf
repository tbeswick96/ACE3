#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Adds ACE interaction menu actions for seeker type selection.
 * Scans turret magazines for guided ammo with multiple seeker types and creates child actions for each.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ace_missileguidance_fnc_setupSeekerActions
 *
 * Public: No
 */

params ["_player"];

if (!alive _player) exitWith {};

private _vehicle = vehicle _player;

if (_player == _vehicle) exitWith {};

if (_vehicle getVariable [QGVAR(seekerActionsAdded), false]) exitWith {};

private _turretPath = _vehicle unitTurret _player;
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

// Collect all unique seeker types from magazines on this turret that have multiple seekers
private _allSeekerTypes = [];
{
    private _ammo = getText (_cfgMagazines >> _x >> "ammo");
    private _config = _cfgAmmo >> _ammo >> QUOTE(ADDON);

    if ((getNumber (_config >> "enabled")) != 1) then { continue };

    private _seekerTypes = getArray (_config >> "seekerTypes");
    if (count _seekerTypes <= 1) then { continue };

    {
        _allSeekerTypes pushBackUnique _x;
    } forEach _seekerTypes;
} forEach (_vehicle magazinesTurret _turretPath);

if (_allSeekerTypes isEqualTo []) exitWith {};

_vehicle setVariable [QGVAR(seekerActionsAdded), true];
TRACE_2("adding seeker type actions",_vehicle,_allSeekerTypes);

// Parent action
private _parentAction = [QGVAR(seekerTypeAction), LLSTRING(SeekerTypeAction), "", {}, {true}] call EFUNC(interact_menu,createAction);
private _basePath = [_vehicle, 1, ["ACE_SelfActions"], _parentAction] call EFUNC(interact_menu,addActionToObject);

// Statement for child actions
private _fnc_statement = {
    params ["_target", "", "_seekerType"];
    TRACE_2("seeker type selected",_target,_seekerType);

    _target setVariable [QGVAR(seekerType), _seekerType, false];

    playSound "ACE_Sound_Click";

    private _localisedName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
    if (_localisedName == "") then {
        _localisedName = _seekerType;
    };
    [_localisedName] call EFUNC(common,displayTextStructured);
};

// Condition for child actions
private _fnc_condition = {
    params ["_target", "", "_seekerType"];

    (_target getVariable [QGVAR(seekerType), "#undefined"]) != _seekerType
};

// Create a child action for each unique seeker type
{
    private _seekerType = _x;
    private _localisedName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
    if (_localisedName == "") then {
        _localisedName = _seekerType;
    };

    private _action = [format [QGVAR(seekerType_%1), _seekerType], _localisedName, "", _fnc_statement, _fnc_condition, {}, _seekerType] call EFUNC(interact_menu,createAction);
    [_vehicle, 1, _basePath, _action] call EFUNC(interact_menu,addActionToObject);
} forEach _allSeekerTypes;

TRACE_2("seeker type interactions added",_vehicle,typeOf _vehicle);
