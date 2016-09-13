/*
 * Author: BaerMitUmlaut
 * Removes a duty factor.
 *
 * Arguments:
 * 0: Factor ID <STRING>
 *
 * Return Value:
 * None
 */
#include "script_component.hpp"
params [["_id", "", [""]]];

GVAR(dutyList) params ["_idList", "_factorList"];
private _index = _idList find _id;

if (_index != -1) then {
    _idList deleteAt _index;
    _factorList deleteAt _index;
};
