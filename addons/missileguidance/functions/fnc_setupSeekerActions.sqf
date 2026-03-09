#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Adds ACE interaction menu actions for seeker type selection.
 * Uses dynamic children filtered to the current weapon's ammo, storing selection per-ammo in a hashmap.
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

// Check if any magazine on this turret has multiple seeker types
private _hasMultipleSeekers = false;
{
    private _ammo = getText (_cfgMagazines >> _x >> "ammo");
    private _config = _cfgAmmo >> _ammo >> QUOTE(ADDON);

    if ((getNumber (_config >> "enabled")) != 1) then { continue };

    private _seekerTypes = getArray (_config >> "seekerTypes");
    if (count _seekerTypes > 1) exitWith { _hasMultipleSeekers = true };
} forEach (_vehicle magazinesTurret _turretPath);

if (!_hasMultipleSeekers) exitWith {};

_vehicle setVariable [QGVAR(seekerActionsAdded), true];
TRACE_1("adding seeker type actions",_vehicle);

// Initialise the per-ammo seeker type hashmap if not already present
if (isNil { _vehicle getVariable QGVAR(seekerTypes) }) then {
    _vehicle setVariable [QGVAR(seekerTypes), createHashMap, false];
};

// Parent action with dynamic children
private _parentAction = [
    QGVAR(seekerTypeAction),
    LLSTRING(SeekerTypeAction),
    "",
    {},
    { true },
    {
        params ["_target", "_player"];

        private _turretPath = _target unitTurret _player;
        private _currentMagazine = _target currentMagazineTurret _turretPath;
        if (_currentMagazine == "") exitWith { [] };

        private _ammo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");
        private _config = configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON);

        if ((getNumber (_config >> "enabled")) != 1) exitWith { [] };

        private _seekerTypes = getArray (_config >> "seekerTypes");
        if (count _seekerTypes <= 1) exitWith { [] };

        // Get the seeker type hashmap
        private _seekerTypeMap = _target getVariable [QGVAR(seekerTypes), createHashMap];
        private _currentSeekerType = _seekerTypeMap getOrDefault [_ammo, ""];

        private _actions = [];
        {
            private _seekerType = _x;

            // Skip if already selected for this ammo
            if (_seekerType == _currentSeekerType) then { continue };

            private _localisedName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
            if (_localisedName == "") then {
                _localisedName = _seekerType;
            };

            private _action = [
                format [QGVAR(seekerType_%1), _seekerType],
                _localisedName,
                "",
                {
                    params ["_target", "_player", "_seekerType"];
                    TRACE_2("seeker type selected",_target,_seekerType);

                    private _turretPath = _target unitTurret _player;
                    private _currentMagazine = _target currentMagazineTurret _turretPath;
                    private _ammo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");

                    private _seekerTypeMap = _target getVariable [QGVAR(seekerTypes), createHashMap];
                    _seekerTypeMap set [_ammo, _seekerType];
                    _target setVariable [QGVAR(seekerTypes), _seekerTypeMap, false];

                    playSound "ACE_Sound_Click";

                    private _localisedName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
                    if (_localisedName == "") then {
                        _localisedName = _seekerType;
                    };
                    [_localisedName] call EFUNC(common,displayTextStructured);
                },
                { true },
                {},
                _seekerType
            ] call EFUNC(interact_menu,createAction);
            _actions pushBack [_action, [], _target];
        } forEach _seekerTypes;

        _actions
    }
] call EFUNC(interact_menu,createAction);

[_vehicle, 1, ["ACE_SelfActions"], _parentAction] call EFUNC(interact_menu,addActionToObject);

TRACE_2("seeker type interactions added",_vehicle,typeOf _vehicle);
