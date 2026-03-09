#include "..\script_component.hpp"
/*
 * Author: tcvm
 * Register default HUD for most missiles.
 *
 * Arguments:
 * Nothing
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [] call ace_missile_hud_fnc_registerDefaultHud
 *
 * Public: No
 */

[{
    // Condition: does any pylon magazine on this turret have a HUD-capable seeker or named attack profile?
    params ["_unit", "_vehicle", "_weapon"];
    private _turretPath = _vehicle unitTurret _unit;
    private _pylons = (getAllPylonsInfo _vehicle) select { (_x select 2) isEqualTo _turretPath };
    private _hasAttackMode = false;
    private _seekerTypeMap = _vehicle getVariable [QEGVAR(missileguidance,seekerTypes), createHashMap];
    scopeName "cond";
    {
        _x params ["", "", "", "_magazine"];
        private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
        private _ammoConfig = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
        private _attackProfiles = getArray (_ammoConfig >> "attackProfiles");
        private _seekerTypes = getArray (_ammoConfig >> "seekerTypes");

        // Check all seeker types for hudInfo
        {
            private _hudFnc = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _x >> "hudInfo");
            if (_hudFnc != "") exitWith { _hasAttackMode = true; breakTo "cond" };
        } forEach _seekerTypes;

        {
            private _config = configFile >> QEGVAR(missileguidance,AttackProfiles) >> _x;
            if (getText (_config >> "name") != "" || getText (_config >> "nameLocked") != "") exitWith {
                _hasAttackMode = true;
                breakTo "cond";
            }
        } forEach _attackProfiles;
    } forEach _pylons;
    _hasAttackMode
}, {
    // Setup: build per-magazine details
    params ["_unit", "_vehicle", "_weapon"];
    private _magazineDetails = createHashMap;

    private _turretPath = _vehicle unitTurret _unit;
    private _pylons = (getAllPylonsInfo _vehicle) select { (_x select 2) isEqualTo _turretPath };
    {
        _x params ["", "", "", "_magazine"];
        private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
        private _ammoConfig = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
        private _defaultAttackProfile = getText (_ammoConfig >> "defaultAttackProfile");
        private _attackProfiles = getArray (_ammoConfig >> "attackProfiles");
        private _seekerTypes = getArray (_ammoConfig >> "seekerTypes");
        private _hasSeekerStates = (getArray (_ammoConfig >> "seekerStates" >> "states")) isNotEqualTo [];
        private _modes = createHashMap;
        {
            private _config = configFile >> QEGVAR(missileguidance,AttackProfiles) >> _x;
            _modes set [_x, [getText (_config >> "name"), getText (_config >> "nameLocked")]];
        } forEach _attackProfiles;

        _magazineDetails set [_magazine, [_modes, _defaultAttackProfile, _ammoConfig, _ammo, _seekerTypes, _hasSeekerStates]];
    } forEach _pylons;

    [_magazineDetails]
}, {
    // Generator: produce HUD elements per frame
    params ["_unit", "_vehicle", "_weapon", "_params"];
    _params params ["_magazineDetails"];
    private _turretPath = _vehicle unitTurret _unit;
    private _magazine = _vehicle currentMagazineTurret _turretPath;
    if !(_magazine in _magazineDetails) exitWith { [] };
    (_magazineDetails get _magazine) params ["_modes", "_defaultAttackProfile", "_ammoConfig", "_ammo", "_seekerTypes", "_hasSeekerStates"];

    private _seekerTypeMap = _vehicle getVariable [QEGVAR(missileguidance,seekerTypes), createHashMap];
    private _selectedSeeker = _seekerTypeMap getOrDefault [_ammo, ""];

    private _mode = _vehicle getVariable [QEGVAR(missileguidance,attackProfile), _defaultAttackProfile];
    (_modes getOrDefault [_mode, ["", ""]]) params ["_idleDisplay", "_lockedDisplay"];

    if (_hasSeekerStates) then {
        // State-machine munition: show HUD for ALL seeker types that have hudInfo
        private _groups = [];
        {
            private _hudFnc = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _x >> "hudInfo");
            if (_hudFnc == "") then { continue };

            private _hudResult = [_idleDisplay, _lockedDisplay, _unit, _vehicle, _ammoConfig] call (missionNamespace getVariable [_hudFnc, { [] }]);
            if (_hudResult isEqualTo []) then { continue };

            if ((_hudResult select 0) isEqualType "") then {
                _groups pushBack [_hudResult];
            } else {
                _groups pushBack _hudResult;
            };
        } forEach _seekerTypes;

        // Return array of groups (multi-group format)
        _groups
    } else {
        // User-selectable munition: show HUD for only the selected seeker
        private _hudFnc = "";
        if (_selectedSeeker != "") then {
            _hudFnc = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _selectedSeeker >> "hudInfo");
        };
        // Fall back to default seeker's hudInfo
        if (_hudFnc == "") then {
            private _defaultSeeker = getText (_ammoConfig >> "defaultSeekerType");
            _hudFnc = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _defaultSeeker >> "hudInfo");
        };

        if (_hudFnc == "" && _idleDisplay == "") exitWith { [] };

        if (_hudFnc != "") then {
            [_idleDisplay, _lockedDisplay, _unit, _vehicle, _ammoConfig] call (missionNamespace getVariable [_hudFnc, { [] }])
        } else {
            ["TEXT", _idleDisplay, [1, 1, 1]]
        };
    };
}] call FUNC(registerElement);
