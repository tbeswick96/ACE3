/*
 * Author: commy2
 * Initialized the assigned item fix.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public : No
 */
#include "script_component.hpp"

ACE_isMapEnabled     = call {private _config = missionConfigFile >> "showMap";     !isNumber _config || {getNumber _config == 1}};  // default value is 1, so do isNumber check first
ACE_isCompassEnabled = call {private _config = missionConfigFile >> "showCompass"; !isNumber _config || {getNumber _config == 1}};
ACE_isWatchEnabled   = call {private _config = missionConfigFile >> "showWatch";   !isNumber _config || {getNumber _config == 1}};
ACE_isRadioEnabled   = call {private _config = missionConfigFile >> "showRadio";   !isNumber _config || {getNumber _config == 1}};
ACE_isGPSEnabled     = call {private _config = missionConfigFile >> "showGPS";     !isNumber _config || {getNumber _config == 1}};

GVAR(AssignedItems) = [];
GVAR(AssignedItemsInfo) = [];
GVAR(AssignedItemsShownItems) = [
    ACE_isMapEnabled,
    ACE_isCompassEnabled,
    ACE_isWatchEnabled,
    ACE_isRadioEnabled,
    ACE_isGPSEnabled
];

["loadout", {
    params ["_unit"];

    private _assignedItems = getUnitLoadout _unit param [9, ["","","","","",""]]; // ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","NVGoggles"]

    GVAR(AssignedItemsShownItems) = [
        !((_assignedItems select 0) isEqualTo "") && {getText (configFile >> "CfgWeapons" >> _assignedItems select 0 >> "ACE_hideItemType") != "map"},
        !((_assignedItems select 3) isEqualTo "") && {getText (configFile >> "CfgWeapons" >> _assignedItems select 3 >> "ACE_hideItemType") != "compass"},
        !((_assignedItems select 4) isEqualTo "") && {getText (configFile >> "CfgWeapons" >> _assignedItems select 4 >> "ACE_hideItemType") != "watch"},
        !((_assignedItems select 2) isEqualTo "") && {getText (configFile >> "CfgWeapons" >> _assignedItems select 2 >> "ACE_hideItemType") != "radio"},
        !((_assignedItems select 1) isEqualTo "") && {getText (configFile >> "CfgWeapons" >> _assignedItems select 1 >> "ACE_hideItemType") != "gps"}
    ];

    GVAR(AssignedItemsShownItems) params ["_showMap", "_showCompass", "_showWatch", "_showRadio", "_showGPS"];

    showMap _showMap;
    showCompass _showCompass;
    showWatch _showWatch;
    showRadio _showRadio;
    showGPS (_showGPS || {cameraOn == getConnectedUAV _unit});  //If player is activly controling a UAV, showGPS controls showing the map (m key)
}] call CBA_fnc_addPlayerEventHandler;
