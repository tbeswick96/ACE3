#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Loads the active target hashmap entry into the dialog UI fields.
 * Handles empty/default entries by clearing fields.
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

private _entry = GVAR(targetSettings) get GVAR(activeTarget);
private _position = _entry get "position";
private _impactAngle = _entry get "impactAngle";
private _attackHeading = _entry get "attackHeading";
private _height = _entry get "height";
private _cruiseAltitude = _entry get "cruiseAltitude";

// Populate target fields
if (_position isEqualTo [0, 0, 0]) then {
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText "";
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText "";
} else {
    private _pos2D = [_position select 0, _position select 1];
    private _mapGrid = [_pos2D] call EFUNC(common,getMapGridFromPos);
    _mapGrid params ["_easting", "_northing"];
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText _easting;
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText _northing;
};

(_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT) ctrlSetText (if (_height == 0) then {""} else {str _height});
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_ANGLE) ctrlSetText (if (_impactAngle < 0) then {""} else {str (round _impactAngle)});
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING) ctrlSetText (if (_attackHeading < 0) then {""} else {str (round _attackHeading)});

// Populate cruise altitude combo
private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
private _altitudeIndex = [50, 100, 150] find _cruiseAltitude;
_combo lbSetCurSel ([_altitudeIndex, 1] select (_altitudeIndex < 0));

// Update target label
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_LABEL) ctrlSetText format ["TGT %1", GVAR(activeTarget) + 1];

// Refresh waypoint list for this target's waypoints
call FUNC(planner_updateList);

TRACE_2("planner_loadTarget",GVAR(activeTarget),_position);
