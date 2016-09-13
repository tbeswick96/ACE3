/*
 * Author: esteldunedain
 * Check if the target has an MG equiped with belt system that the player can link
 *
 * Arguments:
 * 0: Player <OBJECT>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * Can link belt<BOOL>
 *
 * Example:
 * [player, cursorObject] call ace_reload_fnc_canLinkBelt;
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_player", "_target"];

if (vehicle _target != _target) exitWith {false};

private _magazineType = currentMagazine _target;
private _magazineCfg = configFile >> "CfgMagazines" >> _magazineType;

if (getNumber (_magazineCfg >> "ACE_isBelt") == 0) exitWith {false};

// Check if the ammo is not empty or full
private _ammoCount = _target ammo currentWeapon _target;

// Exit if the belt is full or empty
if (_ammoCount == 0 || getNumber (_magazineCfg >> "count") - _ammoCount == 0) exitWith {false};

// Check if the player has any of the same magazines
// Calculate max ammo
private _maxAmmo = 0;

{
    _maxAmmo = _maxAmmo max (_x select 1);
} forEach (magazinesAmmo _player select {_x select 0 == _magazineType});

_maxAmmo > 0
