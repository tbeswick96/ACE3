/*
 * Author: PabstMirror
 * Handles when a unit is kill.  Reset captivity and escorting status
 *
 * Arguments:
 * 0: _oldUnit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [bob1] call ACE_captives_fnc_handleKilled
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_1(_oldUnit);

if (!local _oldUnit) exitWith {};

// TODO implement? What do we want to do here again? Hide the Hud elements?
// Reset the variables?

if (true) exitWith {};
