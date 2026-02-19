#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on unload of cruise planner dialog.
 * Saves target fields and cruise mode to vehicle variables,
 * removes map draw PFH, and cleans up map click handlers.
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

if (!isNull _display) then {
    private _vehicle = vehicle ACE_PLAYER;

    // Save target fields to vehicle variable
    private _eastingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING);
    private _northingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING);
    private _heightStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT);
    private _angleStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_ANGLE);
    private _headingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING);

    if (_eastingStr isNotEqualTo "" && {_northingStr isNotEqualTo ""}) then {
        private _gridStr = _eastingStr + _northingStr;
        private _pos2D = [_gridStr] call EFUNC(common,getMapPosFromGrid);

        private _terrainASL = getTerrainHeightASL _pos2D;
        private _heightOffset = if (_heightStr isEqualTo "") then {0} else {parseNumber _heightStr};
        private _posASL = [_pos2D select 0, _pos2D select 1, _terrainASL + _heightOffset];

        private _impactAngle = if (_angleStr isEqualTo "") then {-1} else {parseNumber _angleStr};
        private _attackHeading = if (_headingStr isEqualTo "") then {-1} else {parseNumber _headingStr};

        _vehicle setVariable [QGVAR(cruiseTargetSettings), [+_posASL, _impactAngle, _attackHeading], true];
        TRACE_3("cruise_planner_close saved target",_posASL,_impactAngle,_attackHeading);
    };

    // Save cruise mode from combo box
    private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
    private _selIndex = lbCurSel _combo;
    if (_selIndex >= 0) then {
        private _modes = ["low_tf", "high_tf", "cruise"];
        _vehicle setVariable [QGVAR(cruiseMode), _modes select _selIndex, true];
    };

    // Remove any pending map click handlers
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlRemoveAllEventHandlers "MouseButtonClick";
};

// Remove map draw PFH
[GVAR(cruisePlanner_drawPFH)] call CBA_fnc_removePerFrameHandler;
