/*
 * Author: Jonpas
 * Applies custom tag to the cache.
 *
 * Arguments:
 * 0: Unique Identifier <STRING>
 * 1: Display Name <STRING>
 * 2: Required Item <STRING>
 * 3: Textures Paths <ARRAY>
 * 4: Icon Path <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["ace_victoryRed", "Victory Red", "ACE_SpraypaintRed", ["path\to\texture1.paa", "path\to\texture2.paa"], "path\to\icon.paa"] call ace_tagging_fnc_applyCustomTag
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_identifier", "_displayName", "_requiredItem"];

// Add only if tag not already added (compare identifiers)
if !(GVAR(cachedTags) select {_x select 0 == _identifier} isEqualTo []) exitWith {
    ACE_LOGINFO_2("Tag with selected identifier already exists: %1 (%2)",_identifier,_displayName)
};

GVAR(cachedTags) pushBack _this;
GVAR(cachedRequiredItems) pushBackUnique _requiredItem;
TRACE_1("Added custom script tag",_this);
