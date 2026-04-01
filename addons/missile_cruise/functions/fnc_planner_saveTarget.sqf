#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Saves current dialog UI fields to the active target hashmap entry (PP mode)
 * or TOO settings hashmap (TOO mode).
 * Waypoints are already written directly to the hashmap by waypoint functions,
 * so only UI text fields and cruise altitude need saving here.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];
if (isNull _display) exitWith {};

private _angleStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_ANGLE);
private _headingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING);
private _impactAngle = if (_angleStr isEqualTo "") then {-1} else {parseNumber _angleStr};
private _attackHeading = if (_headingStr isEqualTo "") then {-1} else {parseNumber _headingStr};

// Save cruise altitude from combo
private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
private _selIndex = lbCurSel _combo;
private _altitudes = [50, 100, 150];
private _cruiseAltitude = if (_selIndex >= 0) then {_altitudes select _selIndex} else {100};

if (GVAR(plannerMode) isEqualTo "too") then {
    GVAR(tooSettings) set ["impactAngle", _impactAngle];
    GVAR(tooSettings) set ["attackHeading", _attackHeading];
    GVAR(tooSettings) set ["cruiseAltitude", _cruiseAltitude];
    TRACE_2("planner_saveTarget TOO",_impactAngle,_attackHeading);
} else {
    private _entry = GVAR(targetSettings) get GVAR(activeTarget);

    private _eastingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING);
    private _northingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING);
    private _heightStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT);

    // Parse position from grid fields
    private _position = [0, 0, 0];
    if (_eastingStr isNotEqualTo "" && {_northingStr isNotEqualTo ""}) then {
        private _gridStr = _eastingStr + _northingStr;
        private _pos2D = [_gridStr] call EFUNC(common,getMapPosFromGrid);
        private _terrainASL = getTerrainHeightASL _pos2D;
        private _heightOffset = if (_heightStr isEqualTo "") then {0} else {parseNumber _heightStr};
        _position = [_pos2D select 0, _pos2D select 1, _terrainASL + _heightOffset];
    };

    private _height = if (_heightStr isEqualTo "") then {0} else {parseNumber _heightStr};

    _entry set ["position", _position];
    _entry set ["impactAngle", _impactAngle];
    _entry set ["attackHeading", _attackHeading];
    _entry set ["height", _height];
    _entry set ["cruiseAltitude", _cruiseAltitude];
    // waypoints already in hashmap — not saved here

    TRACE_3("planner_saveTarget PP",GVAR(activeTarget),_position,_attackHeading);
};
