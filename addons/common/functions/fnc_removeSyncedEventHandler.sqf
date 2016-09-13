/*
 * Author: jaynus
 * Remove a synced event handler
 *
 * Arguments:
 * 0: Name <STRING>
 *
 * Return Value:
 * Boolean of success
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_name"];

if !([GVAR(syncedEvents), _name] call CBA_fnc_hashHasKey) exitWith {
    ACE_LOGERROR_1("Synced event key [%1] not found (removeSyncedEventHandler).", _name);
    false
};

private _data = [GVAR(syncedEvents), _name] call CBA_fnc_hashGet;
_data params ["", "", "", "_eventId"];

[_eventId] call CBA_fnc_removeEventHandler;
[GVAR(syncedEvents), _name] call CBA_fnc_hashRem;
