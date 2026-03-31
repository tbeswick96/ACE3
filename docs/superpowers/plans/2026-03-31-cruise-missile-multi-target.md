# Cruise Missile Multi-Target Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand the cruise missile planner from 1 target to 4 independent pre-planned target entries with per-target waypoints, cruise altitude, and all target fields.

**Architecture:** Hashmap-based storage (`GVAR(targetSettings)`) with 4 entries keyed 0-3. Each entry is a hashmap containing position, impactAngle, attackHeading, height, cruiseAltitude, and waypoints. Dialog adds `<<`/`>>` cycle buttons. Save/load functions sync UI state with the hashmap on cycle and dialog close. `fnc_onFired` deep-copies the active entry so in-flight missiles are isolated.

**Tech Stack:** SQF (Arma 3), CBA macros, ACE framework, HEMTT build system

**Spec:** `docs/superpowers/specs/2026-03-31-cruise-missile-multi-target-design.md`

---

### Task 1: Add MAX_CRUISE_TARGETS define and hashmap initialisation

**Files:**
- Modify: `addons/missile_cruise/script_component.hpp:17`
- Modify: `addons/missile_cruise/XEH_preInit.sqf`

- [ ] **Step 1: Add define to script_component.hpp**

Add `MAX_CRUISE_TARGETS` after the existing `#include` at the end of the file:

```sqf
#include "\z\ace\addons\main\script_macros.hpp"

#define MAX_CRUISE_TARGETS 4
```

- [ ] **Step 2: Initialise hashmap and activeTarget in XEH_preInit.sqf**

Replace the current content of `XEH_preInit.sqf` with:

```sqf
#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(weapons) = createHashMap;
GVAR(activeTarget) = 0;
GVAR(targetSettings) = createHashMap;
for "_i" from 0 to (MAX_CRUISE_TARGETS - 1) do {
    GVAR(targetSettings) set [_i, createHashMapFromArray [
        ["position", [0, 0, 0]],
        ["impactAngle", -1],
        ["attackHeading", -1],
        ["height", 0],
        ["cruiseAltitude", 100],
        ["waypoints", []]
    ]];
};

ADDON = true;
```

- [ ] **Step 3: Commit**

```
git add addons/missile_cruise/script_component.hpp addons/missile_cruise/XEH_preInit.sqf
git commit -m "feat(missile_cruise): add multi-target hashmap initialisation"
```

---

### Task 2: Add new IDCs and dialog cycle controls

**Files:**
- Modify: `addons/missile_cruise/idc_defines.hpp`
- Modify: `addons/missile_cruise/CruisePlannerDialog.hpp`

- [ ] **Step 1: Add new IDC constants to idc_defines.hpp**

Add 3 new IDCs after the existing defines. The current file defines IDCs in the `17043xx` range. Add:

```sqf
#define CRUISE_PLANNER_IDC_TGT_PREV 1704317
#define CRUISE_PLANNER_IDC_TGT_NEXT 1704318
#define CRUISE_PLANNER_IDC_TGT_LABEL 1704319
```

- [ ] **Step 2: Add cycle controls to CruisePlannerDialog.hpp**

Insert the target cycling row between the `TargetHeader` and `EastingLabel` controls. This requires shifting all existing target-section controls down by `1.2 * GUI_GRID_H` to make room.

Add these 3 new controls immediately after `TargetHeader` (at y = `5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y`, which is the row currently used by Easting — we insert before it):

```hpp
        // Target cycling controls
        class TgtPrev: RscButton {
            idc = CRUISE_PLANNER_IDC_TGT_PREV;
            text = "<<";
            onButtonClick = QUOTE([-1] call FUNC(planner_cycleTarget));
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0, 0, 0, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class TgtLabel: RscText {
            idc = CRUISE_PLANNER_IDC_TGT_LABEL;
            text = "TGT 1";
            x = QUOTE(24.2 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 1};
            style = 2;
        };
        class TgtNext: RscButton {
            idc = CRUISE_PLANNER_IDC_TGT_NEXT;
            text = ">>";
            onButtonClick = QUOTE([1] call FUNC(planner_cycleTarget));
            x = QUOTE(27.4 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0, 0, 0, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
```

Then shift every existing control below `TargetHeader` down by 1.2 grid units. Apply the following y-coordinate changes:

| Control(s) | Old y multiplier | New y multiplier |
|---|---|---|
| EastingLabel, TgtEasting, NorthingLabel, TgtNorthing | 5.7 | 6.9 |
| HeightLabel, TgtHeight, AngleLabel, TgtAngle | 6.9 | 8.1 |
| HeadingLabel, TgtHeading | 8.1 | 9.3 |
| SetTgtTGP, SetTgtMap | 9.3 | 10.5 |
| CruiseModeLabel, CruiseModeCombo | 10.5 | 11.7 |
| WaypointList | 11.7 | 12.9 |
| InfoText | 16.2 | 17.4 |
| AddFromTGP, AddFromMap | 17.4 | 18.6 |
| MoveUp, MoveDown, Delete, ClearAll, SaveButton | 18.6 | 19.8 |

The dialog background height also needs to grow by 1.2 grid units. Change the `Background` control:
- Old: `h = QUOTE(16 * GUI_GRID_H);`
- New: `h = QUOTE(17.2 * GUI_GRID_H);`

- [ ] **Step 3: Commit**

```
git add addons/missile_cruise/idc_defines.hpp addons/missile_cruise/CruisePlannerDialog.hpp
git commit -m "feat(missile_cruise): add target cycle controls to cruise planner dialog"
```

---

### Task 3: Create saveTarget, loadTarget, and cycleTarget functions

**Files:**
- Create: `addons/missile_cruise/functions/fnc_planner_saveTarget.sqf`
- Create: `addons/missile_cruise/functions/fnc_planner_loadTarget.sqf`
- Create: `addons/missile_cruise/functions/fnc_planner_cycleTarget.sqf`
- Modify: `addons/missile_cruise/XEH_PREP.hpp`

- [ ] **Step 1: Create fnc_planner_saveTarget.sqf**

```sqf
#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Saves current dialog UI fields to the active target hashmap entry.
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

private _entry = GVAR(targetSettings) get GVAR(activeTarget);

private _eastingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_EASTING);
private _northingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_NORTHING);
private _heightStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEIGHT);
private _angleStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_ANGLE);
private _headingStr = ctrlText (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING);

// Parse position from grid fields
private _position = [0, 0, 0];
if (_eastingStr isNotEqualTo "" && {_northingStr isNotEqualTo ""}) then {
    private _gridStr = _eastingStr + _northingStr;
    private _pos2D = [_gridStr] call EFUNC(common,getMapPosFromGrid);
    private _terrainASL = getTerrainHeightASL _pos2D;
    private _heightOffset = if (_heightStr isEqualTo "") then {0} else {parseNumber _heightStr};
    _position = [_pos2D select 0, _pos2D select 1, _terrainASL + _heightOffset];
};

private _impactAngle = if (_angleStr isEqualTo "") then {-1} else {parseNumber _angleStr};
private _attackHeading = if (_headingStr isEqualTo "") then {-1} else {parseNumber _headingStr};
private _height = if (_heightStr isEqualTo "") then {0} else {parseNumber _heightStr};

// Save cruise altitude from combo
private _combo = _display displayCtrl CRUISE_PLANNER_IDC_CRUISE_MODE;
private _selIndex = lbCurSel _combo;
private _altitudes = [50, 100, 150];
private _cruiseAltitude = if (_selIndex >= 0) then {_altitudes select _selIndex} else {100};

_entry set ["position", _position];
_entry set ["impactAngle", _impactAngle];
_entry set ["attackHeading", _attackHeading];
_entry set ["height", _height];
_entry set ["cruiseAltitude", _cruiseAltitude];
// waypoints already in hashmap — not saved here

TRACE_3("planner_saveTarget",GVAR(activeTarget),_position,_attackHeading);
```

- [ ] **Step 2: Create fnc_planner_loadTarget.sqf**

```sqf
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
```

- [ ] **Step 3: Create fnc_planner_cycleTarget.sqf**

```sqf
#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Cycles to the next/previous target entry.
 * Saves current UI state, switches active target, loads new entry.
 *
 * Arguments:
 * 0: Direction (-1 = previous, +1 = next) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_direction"];

// Save current UI fields to active target
call FUNC(planner_saveTarget);

// Cycle with wrapping
if (_direction > 0) then {
    GVAR(activeTarget) = (GVAR(activeTarget) + 1) % MAX_CRUISE_TARGETS;
} else {
    GVAR(activeTarget) = GVAR(activeTarget) - 1;
    if (GVAR(activeTarget) < 0) then {
        GVAR(activeTarget) = MAX_CRUISE_TARGETS - 1;
    };
};

// Load new target into UI
call FUNC(planner_loadTarget);

TRACE_1("planner_cycleTarget",GVAR(activeTarget));
```

- [ ] **Step 4: Register new functions in XEH_PREP.hpp**

Add these 3 lines after the existing planner PREPs (after line 24 `PREP(planner_setTargetMap);`):

```sqf
PREP(planner_saveTarget);
PREP(planner_loadTarget);
PREP(planner_cycleTarget);
```

- [ ] **Step 5: Commit**

```
git add addons/missile_cruise/functions/fnc_planner_saveTarget.sqf addons/missile_cruise/functions/fnc_planner_loadTarget.sqf addons/missile_cruise/functions/fnc_planner_cycleTarget.sqf addons/missile_cruise/XEH_PREP.hpp
git commit -m "feat(missile_cruise): add saveTarget, loadTarget, cycleTarget functions"
```

---

### Task 4: Update planner_open and planner_close to use hashmap

**Files:**
- Modify: `addons/missile_cruise/functions/fnc_planner_open.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_close.sqf`

- [ ] **Step 1: Rewrite fnc_planner_open.sqf**

Replace the entire file content:

```sqf
#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on load of cruise planner dialog.
 * Stores display reference, populates cruise altitude combo,
 * loads active target entry, and registers map Draw EH.
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

    // Load active target entry into UI fields
    call FUNC(planner_loadTarget);

    // Refresh list when heading field changes (approach WP depends on heading)
    (_display displayCtrl CRUISE_PLANNER_IDC_TGT_HEADING) ctrlAddEventHandler ["KeyUp", {
        call FUNC(planner_updateList);
    }];

    // Register Draw EH on map control (drawIcon/drawLine require onDraw context)
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlAddEventHandler ["Draw", {
        call FUNC(planner_drawMap);
    }];
}, _this] call CBA_fnc_execNextFrame;
```

- [ ] **Step 2: Rewrite fnc_planner_close.sqf**

Replace the entire file content:

```sqf
#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Called on unload of cruise planner dialog.
 * Saves current UI state to active target entry and cleans up map click handlers.
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
    // Save current UI fields to active target
    call FUNC(planner_saveTarget);

    // Remove any pending map click handlers
    private _map = _display displayCtrl CRUISE_PLANNER_IDC_MAP;
    _map ctrlRemoveAllEventHandlers "MouseButtonClick";
};

// Draw EH on map control is auto-removed when dialog closes
```

- [ ] **Step 3: Commit**

```
git add addons/missile_cruise/functions/fnc_planner_open.sqf addons/missile_cruise/functions/fnc_planner_close.sqf
git commit -m "feat(missile_cruise): update planner open/close to use hashmap"
```

---

### Task 5: Update waypoint functions to use hashmap

**Files:**
- Modify: `addons/missile_cruise/functions/fnc_planner_addFromTGP.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_addFromMap.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_deleteWaypoint.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_moveWaypoint.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_clearAll.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_updateList.sqf`
- Modify: `addons/missile_cruise/functions/fnc_planner_drawMap.sqf`

- [ ] **Step 1: Update fnc_planner_addFromTGP.sqf**

Replace lines 26-28 (the vehicle variable read/write):

Old:
```sqf
private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
_waypoints pushBack _posASL;
_vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];
```

New:
```sqf
private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";
_waypoints pushBack _posASL;
```

- [ ] **Step 2: Update fnc_planner_addFromMap.sqf**

Replace lines 35-37 inside the click handler (the vehicle variable read/write):

Old:
```sqf
    private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
    _waypoints pushBack _posASL;
    _vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];
```

New:
```sqf
    private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";
    _waypoints pushBack _posASL;
```

Also remove lines 33-34 (`private _vehicle` and `if (_vehicle == ACE_PLAYER) exitWith {};`) from inside the click handler since we no longer need the vehicle reference there.

- [ ] **Step 3: Update fnc_planner_deleteWaypoint.sqf**

Replace lines 30-38 (vehicle variable read, bounds check, delete, and write):

Old:
```sqf
private _vehicle = vehicle ACE_PLAYER;
if (_vehicle == ACE_PLAYER) exitWith {};

private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];

if (_wpIndex >= count _waypoints) exitWith {};

_waypoints deleteAt _wpIndex;
_vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];
```

New:
```sqf
private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";

if (_wpIndex >= count _waypoints) exitWith {};

_waypoints deleteAt _wpIndex;
```

- [ ] **Step 4: Update fnc_planner_moveWaypoint.sqf**

Replace lines 31-43 (vehicle variable read, swap, and write):

Old:
```sqf
private _vehicle = vehicle ACE_PLAYER;
if (_vehicle == ACE_PLAYER) exitWith {};

private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];

private _newWpIndex = _wpIndex + _direction;
if (_newWpIndex < 0 || {_newWpIndex >= count _waypoints}) exitWith {};

// Swap
private _temp = _waypoints select _wpIndex;
_waypoints set [_wpIndex, _waypoints select _newWpIndex];
_waypoints set [_newWpIndex, _temp];
_vehicle setVariable [QGVAR(cruiseWaypoints), _waypoints, true];
```

New:
```sqf
private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";

private _newWpIndex = _wpIndex + _direction;
if (_newWpIndex < 0 || {_newWpIndex >= count _waypoints}) exitWith {};

// Swap
private _temp = _waypoints select _wpIndex;
_waypoints set [_wpIndex, _waypoints select _newWpIndex];
_waypoints set [_newWpIndex, _temp];
```

- [ ] **Step 5: Update fnc_planner_clearAll.sqf**

Replace the entire file content:

```sqf
#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Clears all cruise planner waypoints for the active target.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

(GVAR(targetSettings) get GVAR(activeTarget)) set ["waypoints", []];
call FUNC(planner_updateList);
```

- [ ] **Step 6: Update fnc_planner_updateList.sqf**

Replace line 27 (vehicle variable read):

Old:
```sqf
private _vehicle = vehicle ACE_PLAYER;
private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
```

New:
```sqf
private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";
```

Remove the `private _vehicle` line entirely.

- [ ] **Step 7: Update fnc_planner_drawMap.sqf**

Replace lines 21-22 (vehicle variable read):

Old:
```sqf
private _vehicle = vehicle ACE_PLAYER;
private _waypoints = _vehicle getVariable [QGVAR(cruiseWaypoints), []];
```

New:
```sqf
private _vehicle = vehicle ACE_PLAYER;
private _waypoints = (GVAR(targetSettings) get GVAR(activeTarget)) get "waypoints";
```

The `_vehicle` line is kept because it's still used for drawing the vehicle position (line 88-90).

- [ ] **Step 8: Commit**

```
git add addons/missile_cruise/functions/fnc_planner_addFromTGP.sqf addons/missile_cruise/functions/fnc_planner_addFromMap.sqf addons/missile_cruise/functions/fnc_planner_deleteWaypoint.sqf addons/missile_cruise/functions/fnc_planner_moveWaypoint.sqf addons/missile_cruise/functions/fnc_planner_clearAll.sqf addons/missile_cruise/functions/fnc_planner_updateList.sqf addons/missile_cruise/functions/fnc_planner_drawMap.sqf
git commit -m "feat(missile_cruise): update waypoint functions to use hashmap"
```

---

### Task 6: Update onFired to read from hashmap

**Files:**
- Modify: `addons/missile_cruise/functions/fnc_onFired.sqf`

- [ ] **Step 1: Rewrite fnc_onFired.sqf**

Replace the entire file content:

```sqf
#include "..\script_component.hpp"
#include "..\cruise_defines.hpp"
/*
 * Author: UKSF
 * Initializes cruise missile state on fired event.
 * Deep-copies the active target entry from the targetSettings hashmap.
 * Overrides seeker state params so GPS seeker returns our target.
 *
 * Arguments:
 * Guidance Arg Array <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_missile_cruise_fnc_onFired
 *
 * Public: No
 */

params ["_firedEH", "", "", "", "_stateParams", "", ""];
_stateParams params ["", "_seekerStateParams", "_attackProfileStateParams"];
_firedEH params ["_shooter","","","","_ammo","","_projectile"];

// Deep-copy active target entry so in-flight missile is isolated from dialog changes
private _entry = +(GVAR(targetSettings) get GVAR(activeTarget));
private _targetPosition = +(_entry get "position");
private _impactAngle = _entry get "impactAngle";
private _attackDirection = _entry get "attackHeading";
private _cruiseAltitude = _entry get "cruiseAltitude";

// Build GPS-compatible data array: [position, impactAngle, attackDirection]
private _gpsData = [+_targetPosition, _impactAngle, _attackDirection];

// Override seeker state params so GPS seeker frame function returns our target
// (gps_seekerOnFired runs first and writes gps_getAttackData to _seekerStateParams[0],
//  we overwrite it here with our own data)
_seekerStateParams set [0, [+_targetPosition, _impactAngle, _attackDirection]];

// Compute approach waypoint if attack direction is set
private _approachWaypoint = [0, 0, 0];
if (_attackDirection >= 0) then {
    private _reverseDirection = [APPROACH_WAYPOINT_DIST, _attackDirection + 180, 0] call CBA_fnc_polar2vect;
    _approachWaypoint = _targetPosition vectorAdd _reverseDirection;
    _approachWaypoint set [2, ((getTerrainHeightASL _approachWaypoint) max 0) + _cruiseAltitude];
};

private _launchPosition = getPosASL _projectile;

// Deep copy waypoints, filter invalid, reverse for flight order
private _waypoints = +(_entry get "waypoints");
_waypoints = _waypoints select {count _x >= 3};
reverse _waypoints;

// Append approach WP as last waypoint so missile flies through it before popup
if (_approachWaypoint isNotEqualTo [0, 0, 0]) then {
    _waypoints pushBack +_approachWaypoint;
};

// Initialize state params:
// [0] stage, [1] gpsData, [2] cruiseAltitude, [3] approachWaypoint, [4] launchPosition, [5] lastDesiredAltitude, [6] waypoints, [7] currentWaypointIndex
_attackProfileStateParams set [0, STAGE_LAUNCH];
_attackProfileStateParams set [1, _gpsData];
_attackProfileStateParams set [2, _cruiseAltitude];
_attackProfileStateParams set [3, _approachWaypoint];
_attackProfileStateParams set [4, _launchPosition];
_attackProfileStateParams set [5, 0];
_attackProfileStateParams set [6, _waypoints];
_attackProfileStateParams set [7, 0];

TRACE_3("onFired",_targetPosition,_impactAngle,_attackDirection);
```

- [ ] **Step 2: Commit**

```
git add addons/missile_cruise/functions/fnc_onFired.sqf
git commit -m "feat(missile_cruise): update onFired to read from target hashmap"
```

---

### Task 7: Remove stale vehicle variable usage from setupVehicle

**Files:**
- Modify: `addons/missile_cruise/functions/fnc_setupVehicle.sqf`

- [ ] **Step 1: Remove default cruise altitude vehicle variable**

Remove lines 25-28 (the `cruiseAltitude` default setting) since cruise altitude is now per-target in the hashmap:

Old:
```sqf
// Set default cruise altitude if not already set
if (isNil {_vehicle getVariable QGVAR(cruiseAltitude)}) then {
    _vehicle setVariable [QGVAR(cruiseAltitude), 100, true];
};
```

Remove these 4 lines entirely. The default cruise altitude (100) is now set during hashmap initialisation in `XEH_preInit`.

- [ ] **Step 2: Commit**

```
git add addons/missile_cruise/functions/fnc_setupVehicle.sqf
git commit -m "feat(missile_cruise): remove stale cruise altitude vehicle variable from setupVehicle"
```

---

### Task 8: HEMTT build verification

**Files:** None (verification only)

- [ ] **Step 1: Run HEMTT dev build**

```
"C:/Users/Tim/AppData/Local/Microsoft/WinGet/Packages/BrettMayson.HEMTT_Microsoft.Winget.Source_8wekyb3d8bbwe/hemtt.exe" dev
```

Expected: clean build with no errors. Warnings about `sqf.event_unknown` or cross-project prefix collisions are expected (existing HEMTT config handles these).

- [ ] **Step 2: Check for any remaining vehicle variable references**

Search the missile_cruise addon for any remaining references to the removed vehicle variables:

```
grep -r "cruiseTargetSettings\|cruiseWaypoints\|cruiseAltitude" addons/missile_cruise/
```

Expected: no matches (all replaced by hashmap access).

- [ ] **Step 3: Commit build fix if needed**

Only if step 1 or 2 reveals issues.
