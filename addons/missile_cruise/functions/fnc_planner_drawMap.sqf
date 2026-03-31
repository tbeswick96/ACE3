#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * PFH that draws target, approach WP, waypoint path, and vehicle
 * on the planner map control. Reads target from dialog input fields.
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

private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
private _vehicle = vehicle ACE_PLAYER;
private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];

#define WP_ICON "\a3\ui_f\data\map\markers\military\dot_ca.paa"

// Read target from input fields for live preview
private _eastingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING);
private _northingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING);
private _headingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING);

private _hasTarget = _eastingStr isNotEqualTo "" && {_northingStr isNotEqualTo ""};
private _target2D = [0, 0];
private _approachPos2D = [];

if (_hasTarget) then {
    private _gridStr = _eastingStr + _northingStr;
    _target2D = [_gridStr] call EFUNC(common,getMapPosFromGrid);

    // Target icon - red
    _map drawIcon [WP_ICON, [1, 0, 0, 1], _target2D, 24, 24, 45, "TGT", 1, 0.04, "TahomaB", "right"];

    // Attack direction line + approach WP
    if (_headingStr isNotEqualTo "") then {
        private _heading = parseNumber _headingStr;
        private _attackDirVec = [1, _heading, 0] call CBA_fnc_polar2vect;
        private _lineEnd = _target2D vectorAdd [(_attackDirVec select 0) * 3000, (_attackDirVec select 1) * 3000];
        _map drawLine [_target2D, _lineEnd, [1, 1, 1, 0.6]];

        // Approach WP - green
        private _reverseDir = [APPROACH_WAYPOINT_DIST, _heading + 180, 0] call CBA_fnc_polar2vect;
        _approachPos2D = _target2D vectorAdd _reverseDir;
        _map drawIcon [WP_ICON, [0, 1, 0, 1], _approachPos2D, 20, 20, 0, "APP", 1, 0.04, "TahomaB", "right"];

        // Line from approach to target
        _map drawLine [_approachPos2D, _target2D, [0, 1, 0, 0.4]];
    };
};

// Draw waypoint path in flight order (reversed: last array element flown first)
// Numbered: highest = first flown (last in array), WP 1 = last flown (first in array)
private _prevPos = [];
private _wpCount = count _waypoints;
for "_i" from (_wpCount - 1) to 0 step -1 do {
    private _wp = _waypoints#_i;
    if (count _wp < 3) then {continue};
    private _pos2D = [_wp#0, _wp#1];
    private _wpNum = _wpCount - _i;

    _map drawIcon [WP_ICON, [1, 0.8, 0, 1], _pos2D, 20, 20, 0, format ["%1", _wpNum], 1, 0.04, "TahomaB", "right"];

    if (_prevPos isNotEqualTo []) then {
        _map drawLine [_prevPos, _pos2D, [1, 0.8, 0, 0.8]];
    };

    _prevPos = _pos2D;
};

// Connect WP 1 (array[0], last flown) to approach WP or target
if (_prevPos isNotEqualTo [] && {_hasTarget}) then {
    if (_approachPos2D isNotEqualTo []) then {
        _map drawLine [_prevPos, _approachPos2D, [1, 0.8, 0, 0.4]];
    } else {
        _map drawLine [_prevPos, _target2D, [1, 0.8, 0, 0.4]];
    };
};

// Draw vehicle position - green
private _vehiclePos = getPos _vehicle;
private _veh2D = [_vehiclePos select 0, _vehiclePos select 1];
_map drawIcon [WP_ICON, [0, 1, 0, 1], _veh2D, 16, 16, 0, "AC", 1, 0.04, "TahomaB", "right"];

// Connect vehicle to first flown waypoint (last in array) or approach/target
if (_wpCount > 0) then {
    private _lastWP = _waypoints#(_wpCount - 1);
    if (count _lastWP >= 3) then {
        _map drawLine [_veh2D, [_lastWP#0, _lastWP#1], [0, 1, 0, 0.3]];
    };
} else {
    if (_hasTarget) then {
        if (_approachPos2D isNotEqualTo []) then {
            _map drawLine [_veh2D, _approachPos2D, [0, 1, 0, 0.3]];
        } else {
            _map drawLine [_veh2D, _target2D, [0, 1, 0, 0.3]];
        };
    };
};
