#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Cycles seeker type for any missileGuidance enabled ammo that has multiple seeker types
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_missileguidance_fnc_cycleSeekerType
 *
 * Public: No
 */

TRACE_1("cycle seeker type",_this);

if (!alive ACE_player) exitWith {};
if !([ACE_player, objNull, ["isNotInside"]] call EFUNC(common,canInteractWith)) exitWith {};


private _currentShooter = objNull;
private _currentMagazine = "";
private _turretPath = [];
if (isNull (ACE_controlledUAV param [0, objNull])) then {
    if ((isNull objectParent ACE_player) || {ACE_player call CBA_fnc_canUseWeapon}) then {
        _currentShooter = ACE_player;
        _currentMagazine = currentMagazine ACE_player;
    } else {
        _currentShooter = vehicle ACE_player;
        _turretPath = _currentShooter unitTurret ACE_player;
        _currentMagazine = _currentShooter currentMagazineTurret _turretPath;
    };
} else {
    _currentShooter = ACE_controlledUAV select 0;
    _turretPath = ACE_controlledUAV select 2;
    _currentMagazine = _currentShooter currentMagazineTurret _turretPath;
};

if (_currentMagazine == "") exitWith {TRACE_1("no magazine",_currentMagazine)};

private _ammo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");

TRACE_3("",_currentShooter,_currentMagazine,_ammo);

private _configAmmo = configFile >> "CfgAmmo" >> _ammo;
private _config = _configAmmo >> QUOTE(ADDON);

// Bail if guidance is disabled for this ammo
if ((getNumber (_config >> "enabled")) != 1) exitWith {TRACE_1("not enabled",_ammo)};

// Verify ammo has explicity added guidance config (ignore inheritances)
private _configs = QUOTE(configName _x == QUOTE(QUOTE(ADDON))) configClasses _configAmmo;
if (_configs isEqualTo []) exitWith {TRACE_1("not explicity enabled",_ammo)};

private _seekerTypes = getArray (_config >> "seekerTypes");
if ((count _seekerTypes) <= 1) exitWith {TRACE_1("no choices for seeker type",_seekerTypes)};

private _currentSeekerType = _currentShooter getVariable [QGVAR(seekerType), "#undefined"];

// Just like onFired, this is case sensitive!
private _index = _seekerTypes find _currentSeekerType;
if (_index == -1) then {
    _index = _seekerTypes find (getText (_config >> "defaultSeekerType"));
};
_index = (_index + 1) % (count _seekerTypes);
private _nextSeekerType = _seekerTypes select _index;
TRACE_4("",_currentSeekerType,_nextSeekerType,_index,_seekerTypes);

TRACE_2("setVariable seekerType",_currentShooter,_nextSeekerType);
_currentShooter setVariable [QGVAR(seekerType), _nextSeekerType, false];

playSound "ACE_Sound_Click";

private _localisedName = getText (configFile >> QGVAR(SeekerTypes) >> _nextSeekerType >> "name");
if (_localisedName == "") then {
    _localisedName = _nextSeekerType;
};
[_localisedName] call EFUNC(common,displayTextStructured);
