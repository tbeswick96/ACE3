#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on load of cruise planner dialog.
 * Stores display reference, populates cruise altitude combo,
 * loads active target entry, restores mode, and registers PFH + map Draw EH.
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

    // Populate cruise altitude combo (must happen before loadTarget sets selection)
    private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
    _combo lbAdd "50m";
    _combo lbAdd "100m";
    _combo lbAdd "150m";

    // Restore mode (applies enable/disable state, loads target fields)
    private _modeIDC = [CRUISE_PLANNER_IDC_MODE_PP, CRUISE_PLANNER_IDC_MODE_TOO] select (GVAR(plannerMode) isEqualTo "too");
    [_modeIDC] call FUNC(planner_modeSelect);

    // Refresh list when heading field changes (approach WP depends on heading)
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING) ctrlAddEventHandler ["KeyUp", {
        call FUNC(planner_updateList);
    }];

    // Register Draw EH on map control (drawIcon/drawLine require onDraw context)
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlAddEventHandler ["Draw", {
        call FUNC(planner_drawMap);
    }];

    // Register TGP position PFH — updates coordinate fields in TOO mode
    GVAR(plannerPFH) = [{
        if (GVAR(plannerMode) isNotEqualTo "too") exitWith {};

        private _display = uiNamespace getVariable [QGVAR(cruisePlannerDisplay), displayNull];
        if (isNull _display) exitWith {};

        private _vehicle = vehicle ACE_PLAYER;
        if (_vehicle == ACE_PLAYER) exitWith {};

        private _target = getPilotCameraTarget _vehicle;
        _target params ["_tracking", "_position", "_object"];

        if (_position isEqualTo [0, 0, 0]) exitWith {
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText "";
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText "";
            (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT) ctrlSetText "";
        };

        private _mapGrid = [_position] call EFUNC(common,getMapGridFromPos);
        _mapGrid params ["_easting", "_northing"];

        // Height above terrain for display (position is ASL)
        private _heightAboveTerrain = (_position#2) - getTerrainHeightASL _position;

        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING) ctrlSetText _easting;
        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING) ctrlSetText _northing;
        (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT) ctrlSetText str (round (_heightAboveTerrain max 0));
    }] call CBA_fnc_addPerFrameHandler;
}, _this] call CBA_fnc_execNextFrame;
