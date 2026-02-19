#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on load of cruise planner dialog.
 * Stores display reference, populates target fields from vehicle data,
 * populates cruise mode combo, populates waypoint list, and starts map draw PFH.
 *
 * Arguments:
 * Display <DISPLAY> (from onLoad)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

[{
    params ["_display"];
    TRACE_1("cruise_planner_open",_display);
    uiNamespace setVariable [QGVAR(cruisePlannerDisplay), _display];

    private _vehicle = vehicle ACE_PLAYER;

    // Load target settings from vehicle variable
    private _settings = _vehicle getVariable [QGVAR(cruiseTargetSettings), []];

    if (count _settings >= 3) then {
        _settings params ["_targetPos", "_impactAngle", "_attackHeading"];

        if (_targetPos isNotEqualTo [0,0,0]) then {
            private _pos2D = [_targetPos select 0, _targetPos select 1];
            private _mapGrid = [_pos2D] call EFUNC(common,getMapGridFromPos);
            _mapGrid params ["_easting", "_northing"];

            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText _easting;
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText _northing;

            // Height field left empty — close handler derives terrain height from grid.
            // Only populated if user manually enters an override (e.g. elevated target).
        };

        if (_impactAngle > 0) then {
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_ANGLE) ctrlSetText (str (round _impactAngle));
        };

        if (_attackHeading >= 0) then {
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING) ctrlSetText (str (round _attackHeading));
        };
    };

    // Populate cruise mode combo
    private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
    _combo lbAdd "Low TF (50m)";
    _combo lbAdd "High TF (100m)";
    _combo lbAdd "Cruise (150m)";

    private _cruiseMode = _vehicle getVariable [QGVAR(cruiseMode), "high_tf"];
    private _modeIndex = ["low_tf", "high_tf", "cruise"] find _cruiseMode;
    _combo lbSetCurSel ([_modeIndex, 1] select (_modeIndex < 0));

    // Populate waypoint list
    call FUNC(cruise_planner_updateList);

    // Start map draw PFH
    GVAR(cruisePlanner_drawPFH) = [{
        call FUNC(cruise_planner_drawMap);
    }] call CBA_fnc_addPerFrameHandler;
}, _this] call CBA_fnc_execNextFrame;
