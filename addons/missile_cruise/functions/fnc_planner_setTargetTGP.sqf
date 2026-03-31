#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Sets cruise planner target fields from TGP camera target position.
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

private _vehicle = vehicle ACE_PLAYER;
if (_vehicle == ACE_PLAYER) exitWith {};

private _target = getPilotCameraTarget _vehicle;
_target params ["_tracking", "_position", "_object"];

if (_position isEqualTo [0, 0, 0]) exitWith {
    ["No TGP target"] call EFUNC(common,displayTextStructured);
};

// Convert to grid
private _mapGrid = [_position] call EFUNC(common,getMapGridFromPos);
_mapGrid params ["_easting", "_northing"];

// Populate fields — leave height empty so close handler uses terrain height from grid
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText _easting;
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText _northing;
(_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT) ctrlSetText "";

call FUNC(planner_updateList);

TRACE_2("cruise_planner_setTargetTGP",_easting,_northing);
