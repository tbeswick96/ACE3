# Cruise Missile Multi-Target Pre-Planned System

## Overview

Expand the cruise missile planner from a single target to 4 independent pre-planned target entries, following the GPS dialog's PP (pre-planned) pattern. Each entry is a complete mission plan: target position, height, impact angle, attack heading, cruise altitude, and waypoints. The pilot cycles through entries, programs each independently, and fires on each in sequence. In-flight missiles are fully isolated from subsequent dialog changes.

## Data Model

### Storage

A hashmap `GVAR(targetSettings)` initialized in `XEH_preInit` with 4 entries (keys 0-3). Each entry is a hashmap:

```
{
  "position": [0,0,0],
  "impactAngle": -1,
  "attackHeading": -1,
  "height": 0,
  "cruiseAltitude": 100,
  "waypoints": []
}
```

### Active Slot

`GVAR(activeTarget)` (0-3) tracks the currently selected target. Persists across dialog open/close.

### Define

`MAX_CRUISE_TARGETS 4` in `script_component.hpp`.

### Vehicle Variables Removed

- `cruiseTargetSettings` — replaced by hashmap
- `cruiseWaypoints` — replaced by per-target `"waypoints"` in hashmap
- `cruiseAltitude` — replaced by per-target `"cruiseAltitude"` in hashmap

Only `actionsAdded` remains (for `setupVehicle` one-time action registration).

## Dialog UI Changes

### New Controls

Added between the "TARGET" header and the target fields, pushing existing fields down:

- `CRUISE_PLANNER_IDC_TGT_LABEL` — text showing "TGT 1" / "TGT 2" / "TGT 3" / "TGT 4"
- `CRUISE_PLANNER_IDC_TGT_PREV` — `<<` button
- `CRUISE_PLANNER_IDC_TGT_NEXT` — `>>` button

### New IDCs

Added to `idc_defines.hpp`:

- `CRUISE_PLANNER_IDC_TGT_LABEL`
- `CRUISE_PLANNER_IDC_TGT_PREV`
- `CRUISE_PLANNER_IDC_TGT_NEXT`

### Cycle Behaviour

1. Save all current UI fields + waypoints to hashmap at `activeTarget`
2. Increment/decrement `activeTarget` with modulo 4 wrapping
3. Load new entry's fields into UI (empty defaults if no data entered)
4. Refresh waypoint list display
5. Update "TGT N" label

## New Functions

### `fnc_planner_saveTarget`

Reads all UI fields (easting, northing, height, angle, heading, cruise altitude) and the current waypoints from the active hashmap entry, packs everything into a hashmap, and stores it at `GVAR(targetSettings) set [activeTarget, ...]`. Waypoints are read from the hashmap (not a vehicle variable) since waypoint functions write directly to the hashmap.

### `fnc_planner_loadTarget`

Reads from `GVAR(targetSettings) get activeTarget`, populates all UI fields. Handles empty/default entries (blank fields). Refreshes waypoint list.

### `fnc_planner_cycleTarget`

Takes direction (-1/+1). Calls `saveTarget`, increments/decrements `activeTarget` with modulo wrapping, calls `loadTarget`, updates "TGT N" label.

## Modified Functions

### `fnc_planner_open`

- Remove: reading from `cruiseTargetSettings` vehicle variable
- Add: call `loadTarget` for current `activeTarget`
- Add: set "TGT N" label text
- Keep: Draw EH, heading KeyUp EH

### `fnc_planner_close`

- Remove: writing to `cruiseTargetSettings`, `cruiseAltitude`, `cruiseWaypoints` vehicle variables
- Add: call `saveTarget` for current `activeTarget`
- Keep: map click handler cleanup

### `fnc_onFired`

- Remove: reading from `cruiseTargetSettings`, `cruiseWaypoints`, `cruiseAltitude` vehicle variables
- Add: deep-copy from `GVAR(targetSettings) get GVAR(activeTarget)`
- Extract position, impactAngle, attackHeading, cruiseAltitude, waypoints from copied hashmap
- Rest of state initialization unchanged

### `XEH_preInit`

- Add: initialize `GVAR(targetSettings)` hashmap with 4 default entries
- Add: initialize `GVAR(activeTarget) = 0`

### `XEH_PREP.hpp`

- Add: `PREP(planner_saveTarget)`, `PREP(planner_loadTarget)`, `PREP(planner_cycleTarget)`

### Waypoint Functions (read/write hashmap directly)

All updated to use `GVAR(targetSettings) get GVAR(activeTarget) get "waypoints"` instead of vehicle variable:

- `fnc_planner_addFromTGP`
- `fnc_planner_addFromMap`
- `fnc_planner_deleteWaypoint`
- `fnc_planner_moveWaypoint`
- `fnc_planner_clearAll`
- `fnc_planner_updateList`
- `fnc_planner_drawMap`

### `CruisePlannerDialog.hpp`

- Add: `<<`, `>>`, and "TGT N" controls
- Shift existing target fields down to make room

### `idc_defines.hpp`

- Add: 3 new IDC constants

## Functions Unchanged

- `fnc_setupVehicle` — still registers the ACE interaction action
- `fnc_planner_setTargetMap` — still writes to UI fields
- `fnc_planner_setTargetTGP` — still writes to UI fields
- All attack profile, stage, terrain following functions — receive data through `_attackProfileStateParams` set once on fire

## Fire Isolation

On fire, `fnc_onFired` deep-copies the active target entry. The copied data is written into `_attackProfileStateParams` and `_seekerStateParams`. In-flight missiles never re-read from the hashmap. Cycling targets or editing data after fire has no effect on missiles already launched.

Firing does not wipe data. The hashmap entry persists, allowing repeated fires on the same target.

## Laser Code

Handled externally by ACE's existing `fnc_onFiredGetArgs`, which snapshots `ace_laser_code` from the vehicle at fire time. No changes needed. Pilot sets laser code via keybinds before firing.
