#include "script_component.hpp"
/*
 * Author: Dedmen
 * Cache an array of all the compatible items for arsenal.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
*/

private _cargo = [
    [[], [], []], // Weapons 0, primary, secondary, handgun
    [[], [], [], []], // WeaponAccessories 1, optic,side,muzzle,bipod
    [ ], // Magazines 2
    [ ], // Headgear 3
    [ ], // Uniform 4
    [ ], // Vest 5
    [ ], // Backpacks 6
    [ ], // Goggles 7
    [ ], // NVGs 8
    [ ], // Binoculars 9
    [ ], // Map 10
    [ ], // Compass 11
    [ ], // Radio slot 12
    [ ], // Watch slot  13
    [ ], // Comms slot 14
    [ ], // WeaponThrow 15
    [ ], // WeaponPut 16
    [ ] // InventoryItems 17
];

private _configCfgWeapons = configFile >> "CfgWeapons"; //Save this lookup in variable for perf improvement

{
    private _configItemInfo = _x >> "ItemInfo";
    private _simulationType = getText (_x >> "simulation");
    private _className = configName _x;
    private _hasItemInfo = isClass (_configItemInfo);
    private _itemInfoType = if (_hasItemInfo) then {getNumber (_configItemInfo >> "type")} else {0};

    switch true do {
        /* Weapon acc */
        case (
                _hasItemInfo &&
                {_itemInfoType in [TYPE_MUZZLE, TYPE_OPTICS, TYPE_FLASHLIGHT, TYPE_BIPOD]} &&
                {!(configName _x isKindOf ["CBA_MiscItem", (_configCfgWeapons)])}
            ): {

            //Convert type to array index
            (_cargo select 1) select ([TYPE_OPTICS,TYPE_FLASHLIGHT,TYPE_MUZZLE,TYPE_BIPOD] find _itemInfoType) pushBackUnique _className;
        };
        /* Headgear */
        case (_itemInfoType == TYPE_HEADGEAR): {
            (_cargo select 3) pushBackUnique _className;
        };
        /* Uniform */\
        case (_itemInfoType == TYPE_UNIFORM): {
            (_cargo select 4) pushBackUnique _className;
        };
        /* Vest */
        case (_itemInfoType == TYPE_VEST): {
            (_cargo select 5) pushBackUnique _className;
        };
        /* NVgs */
        case (_simulationType == "NVGoggles"): {
            (_cargo select 8) pushBackUnique _className;
        };
        /* Binos */
        case (_simulationType == "Binocular" ||
        ((_simulationType == 'Weapon') && {(getNumber (_x >> 'type') == TYPE_BINOCULAR_AND_NVG)})): {
            (_cargo select 9) pushBackUnique _className;
        };
        /* Map */
        case (_simulationType == "ItemMap"): {
            (_cargo select 10) pushBackUnique _className;
        };
        /* Compass */
        case (_simulationType == "ItemCompass"): {
            (_cargo select 11) pushBackUnique _className;
        };
        /* Radio */
        case (_simulationType == "ItemRadio"): {
            (_cargo select 12) pushBackUnique _className;
        };
        /* Watch */
        case (_simulationType == "ItemWatch"): {
            (_cargo select 13) pushBackUnique _className;
        };
        /* GPS */
        case (_simulationType == "ItemGPS"): {
            (_cargo select 14) pushBackUnique _className;
        };
        /* UAV terminals */
        case (_itemInfoType == TYPE_UAV_TERMINAL): {
            (_cargo select 14) pushBackUnique _className;
        };
        /* Weapon, at the bottom to avoid adding binos */
        case (isClass (_x >> "WeaponSlotsInfo") &&
            {getNumber (_x >> 'type') != TYPE_BINOCULAR_AND_NVG}): {
            switch (getNumber (_x >> "type")) do {
                case TYPE_WEAPON_PRIMARY: {
                    (_cargo select 0) select 0 pushBackUnique (_className call bis_fnc_baseWeapon);
                };
                case TYPE_WEAPON_HANDGUN: {
                    (_cargo select 0) select 2 pushBackUnique (_className call bis_fnc_baseWeapon);
                };
                case TYPE_WEAPON_SECONDARY: {
                    (_cargo select 0) select 1 pushBackUnique (_className call bis_fnc_baseWeapon);
                };
            };
        };
        /* Misc items */
        case (
                _hasItemInfo &&
                (_itemInfoType in [TYPE_MUZZLE, TYPE_OPTICS, TYPE_FLASHLIGHT, TYPE_BIPOD] &&
                {(_className isKindOf ["CBA_MiscItem", (_configCfgWeapons)])}) ||
                {_itemInfoType in [TYPE_FIRST_AID_KIT, TYPE_MEDIKIT, TYPE_TOOLKIT]} ||
                {(getText ( _x >> "simulation")) == "ItemMineDetector"}
            ): {
            (_cargo select 17) pushBackUnique _className;
        };
    };
} foreach configProperties [_configCfgWeapons, "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

private _grenadeList = [];
{
    _grenadeList append getArray (_configCfgWeapons >> "Throw" >> _x >> "magazines");
} foreach getArray (_configCfgWeapons >> "Throw" >> "muzzles");

private _putList = [];
{
    _putList append getArray (_configCfgWeapons >> "Put" >> _x >> "magazines");
} foreach getArray (_configCfgWeapons >> "Put" >> "muzzles");

{
    private _className = configName _x;

    switch true do {
        // Rifle, handgun, secondary weapons mags
        case (
                ((getNumber (_x >> "type") in [TYPE_MAGAZINE_PRIMARY_AND_THROW,TYPE_MAGAZINE_SECONDARY_AND_PUT,1536,TYPE_MAGAZINE_HANDGUN_AND_GL]) ||
                {(getNumber (_x >> QGVAR(hide))) == -1} ||
                {isNumber (_x >> "scopeArsenal") && {getNumber (_x >> "scopeArsenal") == 2}}) &&
                {!(_className in _grenadeList)} &&
                {!(_className in _putList)}
            ): {
            (_cargo select 2) pushBackUnique _className;
        };
        // Grenades
        case (_className in _grenadeList): {
            (_cargo select 15) pushBackUnique _className;
        };
        // Put
        case (_className in _putList): {
            (_cargo select 16) pushBackUnique _className;
        };
    };
} foreach configProperties [(configFile >> "CfgMagazines"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

{
    if (getNumber (_x >> "isBackpack") == 1) then {
        (_cargo select 6) pushBackUnique (configName _x);
    };
} foreach configProperties [(configFile >> "CfgVehicles"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

{
    (_cargo select 7) pushBackUnique (configName _x);
} foreach configProperties [(configFile >> "CfgGlasses"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

private _magazineGroups = [[],[]] call CBA_fnc_hashCreate;

private _cfgMagazines = configFile >> "CfgMagazines";

{
    private _magList = [];
    {
        private _magazines = (getArray _x) select {isClass (_cfgMagazines >> _x)}; //filter out non-existent magazines
        _magazines = _magazines apply {configName (_cfgMagazines >> _x)}; //Make sure classname case is correct
        _magList append _magazines;
    } foreach configProperties [_x, "isArray _x", true];

    [_magazineGroups, toLower configName _x, _magList arrayIntersect _magList] call CBA_fnc_hashSet;
} foreach configProperties [(configFile >> "CfgMagazineWells"), "isClass _x", true];

uiNamespace setVariable [QGVAR(configItems), _cargo];
uiNamespace setVariable [QGVAR(magazineGroups), _magazineGroups];
