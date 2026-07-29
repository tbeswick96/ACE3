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
    // Condition: multi-seeker munition, HUD-capable seeker, or named attack profile on this turret
    params ["_unit", "_vehicle", "_weapon"];
    private _turretPath = _vehicle unitTurret _unit;
    private _pylons = (getAllPylonsInfo _vehicle) select { (_x select 2) isEqualTo _turretPath };
    private _hasAttackMode = false;
    scopeName "cond";
    {
        _x params ["", "", "", "_magazine"];
        private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
        private _ammoConfig = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
        private _attackProfiles = getArray (_ammoConfig >> "attackProfiles");
        private _seekerTypes = getArray (_ammoConfig >> "seekerTypes");

        // Multi-seeker (user-selectable) always gets a mode-line HUD
        if (
            (count _seekerTypes > 1)
            && {(getArray (_ammoConfig >> "seekerStates" >> "states")) isEqualTo []}
        ) exitWith { _hasAttackMode = true; breakTo "cond" };

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
    private _defaultSeeker = getText (_ammoConfig >> "defaultSeekerType");
    private _selectedSeeker = _seekerTypeMap getOrDefault [_ammo, _defaultSeeker];
    if (_selectedSeeker == "" || {!(_selectedSeeker in _seekerTypes)}) then {
        _selectedSeeker = _defaultSeeker;
    };

    private _mode = _vehicle getVariable [QEGVAR(missileguidance,attackProfile), _defaultAttackProfile];
    (_modes getOrDefault [_mode, ["", ""]]) params ["_idleDisplay", "_lockedDisplay"];

    if (_hasSeekerStates) then {
        // State-machine munition: static pre-fire HUD for seekers with hudInfo (no mid-flight updates)
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

        _groups
    } else {
        // User-selectable: prefix the selected seeker's name onto the attack-profile text so
        // the seeker's own HUD keeps its layout and gains no extra element
        if (count _seekerTypes > 1) then {
            private _localisedName = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _selectedSeeker >> "name");
            if (_localisedName == "") then { _localisedName = _selectedSeeker; };
            _idleDisplay = [_localisedName, format ["%1 %2", _localisedName, _idleDisplay]] select (_idleDisplay != "");
            if (_lockedDisplay != "") then {
                _lockedDisplay = format ["%1 %2", _localisedName, _lockedDisplay];
            };
        };

        private _elements = [];

        private _hudFnc = getText (configFile >> QEGVAR(missileguidance,SeekerTypes) >> _selectedSeeker >> "hudInfo");
        if (_hudFnc != "") then {
            private _hudResult = [_idleDisplay, _lockedDisplay, _unit, _vehicle, _ammoConfig] call (missionNamespace getVariable [_hudFnc, { [] }]);
            if (_hudResult isNotEqualTo []) then {
                if ((_hudResult select 0) isEqualType "") then {
                    _elements pushBack _hudResult;
                } else {
                    _elements append _hudResult;
                };
            };
        } else {
            if (_idleDisplay != "") then {
                _elements pushBack ["TEXT", _idleDisplay, [1, 1, 1]];
            };
        };

        if (_elements isEqualTo []) exitWith { [] };
        if (count _elements == 1) exitWith { _elements select 0 };
        _elements
    };
}] call FUNC(registerElement);
