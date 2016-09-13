/*
 * Author: esteldunedain
 * Insert an ACE action to a class, under a certain path
 * Note: This function is NOT global.
 *
 * Arguments:
 * 0: TypeOf of the class <STRING>
 * 1: Type of action, 0 for actions, 1 for self-actions <NUMBER>
 * 2: Parent path of the new action <ARRAY>
 * 3: Action <ARRAY>
 * 4: Use Inheritance <BOOL> (default: false)
 *
 * Return Value:
 * The entry full path, which can be used to remove the entry, or add children entries <ARRAY>.
 *
 * Example:
 * [typeOf cursorTarget, 0, ["ACE_TapShoulderRight"],VulcanPinchAction] call ace_interact_menu_fnc_addActionToClass;
 *
 * Public: Yes
 */
#include "script_component.hpp"

if (!params [["_objectType", "", [""]], ["_typeNum", 0, [0]], ["_parentPath", [], [[]]], ["_action", [], [[]], 11]]) exitWith {
    ERROR("Bad Params");
};
TRACE_4("params",_objectType,_typeNum,_parentPath,_action);

if (param [4, false, [false]]) exitwith {
    if (isNil QGVAR(inheritedActions)) then {GVAR(inheritedActions) = [];};
    private _index = GVAR(inheritedActions) pushBack [[], _typeNum, _parentPath, _action];
    private _initEH = compile format ['
        params ["_object"];
        private _typeOf = typeOf _object;
        (GVAR(inheritedActions) select %1) params ["_addedClasses", "_typeNum", "_parentPath", "_action"];
        if (_typeOf in _addedClasses) exitWith {};
        _addedClasses pushBack _typeOf;
        [_typeOf, _typeNum, _parentPath, _action] call FUNC(addActionToClass);
    ', _index];
    TRACE_2("Added inheritable action",_objectType,_index);
    [_objectType, "init", _initEH, true, [], true] call CBA_fnc_addClassEventHandler;
};

// Ensure the config menu was compiled first
if (_typeNum == 0) then {
    [_objectType] call FUNC(compileMenu);
} else {
    [_objectType] call FUNC(compileMenuSelfAction);
};

private _namespace = [GVAR(ActNamespace), GVAR(ActSelfNamespace)] select _typeNum;
private _actionTrees = _namespace getVariable _objectType;
if (isNil "_actionTrees") then {
    _actionTrees = [];
    _namespace setVariable [_objectType, _actionTrees];
};

if (_parentPath isEqualTo ["ACE_MainActions"]) then {
    [_objectType, _typeNum] call FUNC(addMainAction);
};

private _parentNode = [_actionTrees, _parentPath] call FUNC(findActionNode);
if (isNil {_parentNode}) exitWith {
    ERROR("Failed to add action");
    ACE_LOGERROR_4("action (%1) to parent %2 on object %3 [%4]",(_action select 0),_parentPath,_objectType,_typeNum);
};

// Add action node as children of the correct node of action tree
(_parentNode select 1) pushBack [_action,[]];

// Return the full path
(+ _parentPath) pushBack (_action select 0)
