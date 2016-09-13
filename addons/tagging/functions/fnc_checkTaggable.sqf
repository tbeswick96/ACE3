/*
 * Author: BaerMitUmlaut, esteldunedain
 * Checks if there is a taggable surface within 2.5m in front of the player.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Is surface taggable <BOOL>
 *
 * Example:
 * [unit] call ace_tagging_fnc_checkTaggable
 *
 * Public: No
 */

#include "script_component.hpp"

params ["_unit"];

[[_unit], {
    params ["_unit"];

    // Exit if no required item in inventory
    if ((GVAR(cachedRequiredItems) arrayIntersect ((items _unit) apply {toLower _x})) isEqualTo []) exitWith {false};

    private _startPosASL = eyePos _unit;
    private _cameraPosASL =  AGLToASL positionCameraToWorld [0, 0, 0];
    private _cameraDir = (AGLToASL positionCameraToWorld [0, 0, 1]) vectorDiff _cameraPosASL;
    private _endPosASL = _startPosASL vectorAdd (_cameraDir vectorMultiply 2.5);

    private _intersections = lineIntersectsSurfaces [_startPosASL, _endPosASL, _unit, objNull, true, 1, "FIRE", "GEOM"];

    // If there's no intersections
    if (_intersections isEqualTo []) exitWith {false};

    (_intersections select 0) params ["", "", "", "_object"];

    // Exit if trying to tag a non static object
    TRACE_1("Obj:",_intersections);

    // Exit if trying to tag a non static object
    if ((!isNull _object) && {
        // If the class is alright, do not exit
        if (_object isKindOf "Static") exitWith {false};

        // If the class is not categorized correctly search the cache
        private _array = str(_object) splitString " ";
        private _str = toLower (_array select 1);
        TRACE_1("Object:",_str);
        private _objClass = GVAR(cacheStaticModels) getVariable _str;
        // If the class in not on the cache, exit
        if (isNil "_objClass") exitWith {
            false
        };
        true
    }) exitWith {
        TRACE_1("Pointed object is non static",_object);
        false
    };

    true
}, missionNamespace, QGVAR(checkTaggableCache), 0.5] call EFUNC(common,cachedCall);
