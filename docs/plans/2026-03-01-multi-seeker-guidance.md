# Multi-Seeker Missile Guidance Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable ACE missiles to support multiple seeker types per ammunition — selectable pre-fire via ACE interact and switchable mid-flight via a config-driven state machine — so that munitions like dual-mode SALH/MMW Hellfires and GPS→SALH cruise missiles work correctly.

**Architecture:** Two independent features that share plumbing:
1. **Pre-fire seeker cycling** — a new `fnc_cycleSeekerType` function (mirroring `fnc_cycleAttackProfileKeyDown`) plus per-vehicle ACE interact actions (mirroring Hellfire's `fnc_setupVehicle` pattern). The existing `_shooter getVariable [QGVAR(seekerType)]` path in `fnc_onFiredGetArgs` already reads the selection — no changes needed there.
2. **Mid-flight seeker state machine** — a new `seekerStates` config class (mirroring the existing `navigationStates` pattern) parsed at fire time in `fnc_onFiredGetArgs`, evaluated every frame in `fnc_guidancePFH`, and responsible for calling `onFired` initialisers when transitioning between seekers.

**Tech Stack:** SQF, CBA macros, ACE interact_menu API, CfgAmmo/CfgWeapons config classes. No new addon — all changes in `addons/missileguidance` (and optionally `addons/hellfire` for Hellfire dual-mode config).

---

## Context for the Implementer

### Key File Inventory

| File | Role |
|------|------|
| `addons/missileguidance/functions/fnc_guidancePFH.sqf` | Per-frame guidance loop. Runs seeker → attack profile → navigation → flight control. |
| `addons/missileguidance/functions/fnc_onFiredGetArgs.sqf` | Builds the guidance args array at missile launch. Reads shooter variables, config, calls onFired handlers. |
| `addons/missileguidance/functions/fnc_doSeekerSearch.sqf` | Dispatches to the active seeker function by name. Handles nil/[0,0,0] fallback. |
| `addons/missileguidance/functions/fnc_cycleAttackProfileKeyDown.sqf` | Pre-fire attack profile cycling via keybind. **Primary pattern to clone for seeker cycling.** |
| `addons/missileguidance/ACE_GuidanceConfig.hpp` | Registers all seeker types, attack profiles, and navigation types with their function names and onFired handlers. |
| `addons/missileguidance/CfgMissileTypesNato.hpp` | Defines missile type templates (Hellfire, Javelin, CruiseMissile, etc.) with seeker/profile/nav arrays. |
| `addons/missileguidance/XEH_postInit.sqf` | Registers the Ctrl+Tab keybind for attack profile cycling. |
| `addons/hellfire/functions/fnc_setupVehicle.sqf` | Adds ACE interact actions for Hellfire profile selection. **Primary pattern to clone for seeker interact.** |
| `addons/hellfire/XEH_postInit.sqf` | Event handlers that call `fnc_setupVehicle` on turret/vehicle changes. |

### Guidance Args Array Structure

Built once at fire time in `fnc_onFiredGetArgs`, passed to PFH:

```
_args = [
    _firedEH,           // [0] — [_shooter, "", "", "", _ammo, "", _projectile]
    _launchParams,      // [1] — [_shooter, _targetLaunchParams, _seekerType, _attackProfile, _lockMode, _laserInfo, _navigationType]
    _flightParams,      // [2] — [_pitchRate, _yawRate, _bangBang, _stabilityCoefficient, _showTrail]
    _seekerParams,      // [3] — [_seekerAngle, _seekerAccuracy, _seekerMaxRange, _seekerMinRange]
    _stateParams,       // [4] — [_lastRunTime, _seekerStateParams, _attackProfileStateParams, _lastKnownPosState, _navigationParameters, _guidanceParameters]
    _targetData,        // [5] — [_directionToTarget, _attackProfileDirection, _rangeToTarget, _targetVelocity, _targetAcceleration]
    _navigationStateParams // [6] — [_currentState, _navigationStateData]
]
```

Key indices for this work:
- `_launchParams[2]` = current seeker type name (string)
- `_stateParams[1]` = `_seekerStateParams` (array, seeker-specific state)
- `_stateParams[3]` = `_lastKnownPosState` (array, [_seekLastTargetPos, _lastKnownPos])

### Existing Navigation State Machine (reference pattern)

In `fnc_onFiredGetArgs.sqf` (lines 127-141), `navigationStates` is parsed:
```sqf
private _navigationStateSubclass = _config >> "navigationStates";
private _states = getArray (_navigationStateSubclass >> "states");
private _navigationStateData = [];
if (_states isNotEqualTo []) then {
    {
        private _stateClass = _navigationStateSubclass >> _x;
        _navigationStateData pushBack [
            getText (_stateClass >> "transitionCondition"),
            getText (_stateClass >> "navigationType"),
            []
        ];
    } forEach _states;
};
```

In `fnc_guidancePFH.sqf` (lines 55-68), evaluated every frame:
```sqf
if (_navigationStateData isNotEqualTo []) then {
    (_navigationStateData select _currentState) params ["_transitionCondition"];
    private _transition = ([_args, _timestep] call (missionNamespace getVariable [_transitionCondition, { false }]));
    if (_transition) then {
        _currentState = _currentState + 1;
        _navigationStateParams set [0, _currentState];
    };
    _navigationType = (_navigationStateData select _currentState) select 1;
    _navigationFunction = getText (configFile >> QGVAR(NavigationTypes) >> _navigationType >> "functionName");
    _navigationParameters = (_navigationStateData select _currentState) select 2;
    _stateParams set [4, _navigationParameters];
};
```

### Seeker onFired Handlers

Some seekers need initialisation at fire time. These write to `_seekerStateParams`:

| Seeker | onFired | What it initialises |
|--------|---------|-------------------|
| SALH | *(none)* | Nothing — state built lazily in seeker function via `_seekerParams` defaults |
| GPS | `fnc_gps_seekerOnFired` | `_seekerStateParams[0]` = GPS attack data (target pos, impact angle, attack direction) |
| MWR | `fnc_mwr_onFired` | `_seekerStateParams[0..10]` = radar state (active flag, distances, timers, lock types) |
| IR | `fnc_IR_onFired` | `_seekerStateParams[0..2]` = flare filters + target |
| Doppler | `fnc_doppler_onFired` | Similar to MWR |
| SACLOS | `fnc_SACLOS_onFired` | Wire guidance state |
| MCLOS | `fnc_MCLOS_onFired` | Wire guidance state |

**Critical insight:** When switching seekers mid-flight, `_seekerStateParams` must be reset and the new seeker's onFired must be called. However, SALH also stores averaging state in `_seekerParams` (indices 4-6), which is the *shared* seeker params array — this needs consideration.

### SALH Seeker State

SALH is unusual: it stores its averaging buffer in `_seekerParams` (the shared config array at `_args[3]`), not in `_seekerStateParams`. Specifically:
- `_seekerParams[4]` = `_lastPositions` (array of up to 15 positions)
- `_seekerParams[5]` = `_lastPositionIndex` (counter)
- `_seekerParams[6]` = `_lastPositionSum` (running average)

These default to `[]`, `0`, `[0,0,0]` via the `params` destructuring defaults. When switching TO SALH mid-flight, these will already be at defaults (since they weren't written by the previous seeker), so SALH will naturally start fresh. No special handling needed.

---

## Feature 1: Pre-Fire Seeker Cycling

### Task 1: Create `fnc_cycleSeekerType`

**Files:**
- Create: `addons/missileguidance/functions/fnc_cycleSeekerType.sqf`

This function cycles through `seekerTypes[]` from the current ammo's config, identical in structure to `fnc_cycleAttackProfileKeyDown.sqf` but operating on `seekerType` instead of `attackProfile`.

**Step 1: Create the seeker cycling function**

```sqf
#include "..\script_component.hpp"
/*
 * Author: [yourname]
 * Cycles seeker type for any missileGuidance enabled ammo that has multiple seeker types.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_missileguidance_fnc_cycleSeekerType
 *
 * Public: No
 */

TRACE_1("cycle seeker type",_this);

if (!alive ACE_player) exitWith {};
if !([ACE_player, objNull, ["isNotInside"]] call EFUNC(common,canInteractWith)) exitWith {};

private _currentShooter = objNull;
private _currentMagazine = "";
private _turretPath = [];
if (isNull (ACE_controlledUAV param [0, objNull])) then {
    if ((isNull objectParent ACE_player) || {ACE_player call CBA_fnc_canUseWeapon}) then {
        _currentShooter = ACE_player;
        _currentMagazine = currentMagazine ACE_player;
    } else {
        _currentShooter = vehicle ACE_player;
        _turretPath = _currentShooter unitTurret ACE_player;
        _currentMagazine = _currentShooter currentMagazineTurret _turretPath;
    };
} else {
    _currentShooter = ACE_controlledUAV select 0;
    _turretPath = ACE_controlledUAV select 2;
    _currentMagazine = _currentShooter currentMagazineTurret _turretPath;
};

if (_currentMagazine == "") exitWith {TRACE_1("no magazine",_currentMagazine)};

private _ammo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");

TRACE_3("",_currentShooter,_currentMagazine,_ammo);

private _configAmmo = configFile >> "CfgAmmo" >> _ammo;
private _config = _configAmmo >> QUOTE(ADDON);

// Bail if guidance is disabled for this ammo
if ((getNumber (_config >> "enabled")) != 1) exitWith {TRACE_1("not enabled",_ammo)};

// Verify ammo has explicitly added guidance config (ignore inheritances)
private _configs = QUOTE(configName _x == QUOTE(QUOTE(ADDON))) configClasses _configAmmo;
if (_configs isEqualTo []) exitWith {TRACE_1("not explicitly enabled",_ammo)};

private _seekerTypes = getArray (_config >> "seekerTypes");
if ((count _seekerTypes) <= 1) exitWith {TRACE_1("no choices for seeker type",_seekerTypes)};

private _currentSeekerType = _currentShooter getVariable [QGVAR(seekerType), "#undefined"];

private _index = _seekerTypes find _currentSeekerType;
if (_index == -1) then {
    _index = _seekerTypes find (getText (_config >> "defaultSeekerType"));
};
_index = (_index + 1) % (count _seekerTypes);
private _nextSeekerType = _seekerTypes select _index;
TRACE_4("",_currentSeekerType,_nextSeekerType,_index,_seekerTypes);

_currentShooter setVariable [QGVAR(seekerType), _nextSeekerType, false];

playSound "ACE_Sound_Click";

private _localizedName = getText (configFile >> QGVAR(SeekerTypes) >> _nextSeekerType >> "name");
if (_localizedName == "") then {
    _localizedName = _nextSeekerType;
};
[_localizedName] call EFUNC(common,displayTextStructured);
```

**Step 2: Register the function in XEH_PREP**

In `addons/missileguidance/XEH_preInit.sqf`, the `PREP` macros are auto-generated from the functions directory. Verify that the build system (HEMTT or CBA function auto-prep) will pick up the new file. If the addon uses `PREP_RECOMPILE` or auto-prep from the functions folder, no manual registration is needed.

Check: look at `addons/missileguidance/XEH_preInit.sqf` to confirm auto-prep is used. If functions are listed manually, add:
```sqf
PREP(cycleSeekerType);
```

**Step 3: Verify it compiles**

Run: `hemtt dev` (or however the project builds)
Expected: No errors related to `fnc_cycleSeekerType`

**Step 4: Commit**

```
feat(missileguidance): add pre-fire seeker type cycling function
```

---

### Task 2: Register Seeker Cycling Keybind

**Files:**
- Modify: `addons/missileguidance/XEH_postInit.sqf`

The existing Ctrl+Tab keybind at lines 8-11 cycles attack profiles. Add a new keybind for seeker cycling.

**Step 1: Read `XEH_postInit.sqf` and find the keybind registration block**

Look for the `CBA_fnc_addKeybind` call that registers `cycleFireMode`. Add a second keybind after it.

**Step 2: Add the seeker cycling keybind**

After the existing keybind block, add:

```sqf
[LLSTRING(Category), LSTRING(CycleSeekerType), {
    [] call FUNC(cycleSeekerType);
}, "", [DIK_TAB, [true, true, false]]] call CBA_fnc_addKeybind;
// Default: Ctrl+Shift+Tab (Ctrl+Tab is already used for attack profile cycling)
```

**Note:** The exact key combo is a design choice. `Ctrl+Shift+Tab` avoids conflict with the existing `Ctrl+Tab` for attack profiles. Adjust as desired.

**Step 3: Add stringtable entries**

In `addons/missileguidance/stringtable.xml`, add:

```xml
<Key ID="STR_ACE_MissileGuidance_CycleSeekerType">
    <English>Missile - Cycle Seeker Type</English>
</Key>
```

**Step 4: Verify build**

Run: `hemtt dev`
Expected: No errors. In-game, the keybind should appear in CBA Keybindings under ACE3 Weapons.

**Step 5: Commit**

```
feat(missileguidance): register keybind for seeker type cycling
```

---

### Task 3: Add ACE Interact Actions for Seeker Selection

**Files:**
- Create: `addons/missileguidance/functions/fnc_setupSeekerActions.sqf`
- Modify: `addons/missileguidance/XEH_postInit.sqf` (to call setupSeekerActions on vehicle enter)

This mirrors the Hellfire `fnc_setupVehicle` pattern but is generic — it reads `seekerTypes[]` from the current ammo config and creates interact actions dynamically.

**Step 1: Create the setup function**

```sqf
#include "..\script_component.hpp"
/*
 * Author: [yourname]
 * Adds interaction menu actions to switch seeker type on a vehicle.
 * Only adds actions if any loaded missile has multiple seeker types.
 *
 * Arguments:
 * 0: Player <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player] call ace_missileguidance_fnc_setupSeekerActions
 *
 * Public: No
 */

params ["_player"];
TRACE_1("setupSeekerActions",_player);

if (!alive _player) exitWith {};

private _vehicle = vehicle _player;
if (_player == _vehicle) exitWith {};

// Check if we already added seeker actions to this vehicle
if (_vehicle getVariable [QGVAR(seekerActionsAdded), false]) exitWith {};

private _turretPath = _vehicle unitTurret _player;
private _cfgMagazines = configFile >> "CfgMagazines";

// Find all seeker types available across all loaded guided munitions on this turret
private _allSeekerTypes = [];
private _hasMultipleSeekers = false;
{
    private _magazine = _x;
    private _ammo = getText (_cfgMagazines >> _magazine >> "ammo");
    private _config = configFile >> "CfgAmmo" >> _ammo >> QUOTE(ADDON);

    if ((getNumber (_config >> "enabled")) == 1) then {
        private _seekerTypes = getArray (_config >> "seekerTypes");
        if (count _seekerTypes > 1) then {
            _hasMultipleSeekers = true;
            {
                _allSeekerTypes pushBackUnique _x;
            } forEach _seekerTypes;
        };
    };
} forEach (_vehicle magazinesTurret _turretPath);

if (!_hasMultipleSeekers) exitWith {TRACE_1("no multi-seeker ammo",_vehicle)};

_vehicle setVariable [QGVAR(seekerActionsAdded), true];

// Parent action: "Set Seeker Type"
private _parentAction = [QGVAR(seekerTypeAction), LLSTRING(SeekerTypeAction), "", {}, {true}] call EFUNC(interact_menu,createAction);
private _basePath = [_vehicle, 1, ["ACE_SelfActions"], _parentAction] call EFUNC(interact_menu,addActionToObject);

private _fnc_statement = {
    params ["_target", "", "_seekerType"];
    TRACE_2("seeker statement",_target,_seekerType);
    _target setVariable [QGVAR(seekerType), _seekerType, false];
    playSound "ACE_Sound_Click";

    private _localizedName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
    if (_localizedName == "") then {
        _localizedName = _seekerType;
    };
    [_localizedName] call EFUNC(common,displayTextStructured);
};

private _fnc_condition = {
    params ["_target", "", "_seekerType"];
    (_target getVariable [QGVAR(seekerType), ""]) != _seekerType
};

{
    private _seekerType = _x;
    private _displayName = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "name");
    if (_displayName == "") then {
        _displayName = _seekerType;
    };
    private _action = [format [QGVAR(seeker_%1), _seekerType], _displayName, "", _fnc_statement, _fnc_condition, {}, _seekerType] call EFUNC(interact_menu,createAction);
    [_vehicle, 1, _basePath, _action] call EFUNC(interact_menu,addActionToObject);
} forEach _allSeekerTypes;

TRACE_2("seeker actions added",_vehicle,_allSeekerTypes);
```

**Step 2: Hook into vehicle enter events**

In `addons/missileguidance/XEH_postInit.sqf`, add event handlers to call `fnc_setupSeekerActions` when the player enters a vehicle turret. Follow the same pattern as `addons/hellfire/XEH_postInit.sqf`:

```sqf
// Setup seeker type interact actions when entering vehicles
["turret", {
    params ["_vehicle", "_turret", "_isEntering"];
    if (!_isEntering) exitWith {};
    [ACE_player] call FUNC(setupSeekerActions);
}, true] call CBA_fnc_addPlayerEventHandler;

["vehicle", {
    params ["_vehicle", "_role", "_unit", "_turret"];
    if (_role == "driver" || _unit != ACE_player) exitWith {};
    [ACE_player] call FUNC(setupSeekerActions);
}, true] call CBA_fnc_addPlayerEventHandler;
```

**Step 3: Add stringtable entries**

```xml
<Key ID="STR_ACE_MissileGuidance_SeekerTypeAction">
    <English>Set Seeker Type</English>
</Key>
```

**Step 4: Add display names to seeker types in `ACE_GuidanceConfig.hpp`**

Currently all seeker type `name` fields are empty strings. Fill them in:

```cpp
class SALH {
    name = "SALH";
    // ... rest unchanged
};
class MillimeterWaveRadar {
    name = "MMW Radar";
    // ... rest unchanged
};
class GPS {
    name = "GPS";
    // ... rest unchanged
};
class Optic {
    name = "Optic";
    // ... rest unchanged
};
// etc. for all seeker types
```

Ideally these should be stringtable references (`CSTRING(SeekerName_SALH)`) for localisation, but plain strings work for initial implementation.

**Step 5: Verify build and test**

Run: `hemtt dev`
Test: Load a mission with a Hellfire-armed helicopter. The "Set Seeker Type" interact action should NOT appear (Hellfire only has one seeker type). To test properly, you'd need to temporarily add a second seeker type to the Hellfire config (e.g. `seekerTypes[] = { "SALH", "MillimeterWaveRadar" }`).

**Step 6: Commit**

```
feat(missileguidance): add ACE interact actions for seeker type selection
```

---

## Feature 2: Mid-Flight Seeker State Machine

### Task 4: Parse `seekerStates` Config at Fire Time

**Files:**
- Modify: `addons/missileguidance/functions/fnc_onFiredGetArgs.sqf`

Add parsing of a new `seekerStates` config class, mirroring the existing `navigationStates` parsing at lines 127-141.

**Step 1: Add seekerStates parsing**

After the existing `navigationStates` parsing block (after line 141), add:

```sqf
// Parse seeker state machine (if configured)
private _seekerStateSubclass = _config >> "seekerStates";
private _seekerStates = getArray (_seekerStateSubclass >> "states");

private _seekerStateData = [];

if (_seekerStates isNotEqualTo []) then {
    {
        private _stateClass = _seekerStateSubclass >> _x;
        _seekerStateData pushBack [
            getText (_stateClass >> "transitionCondition"),
            getText (_stateClass >> "seekerType"),
            []  // per-state seeker state params, initialised by onFired
        ];
    } forEach _seekerStates;

    // Override initial seeker type from the first state
    _seekerType = (_seekerStateData select 0) select 1;
    TRACE_2("seekerStates override initial seeker",_seekerType,_seekerStates);
};
```

**Important:** This block must go AFTER the `_seekerType` validation (lines 59-61) but BEFORE the args array is built (line 150). Place it at around line 142, right after the navigation states parsing.

**Step 2: Add seeker state data to the args array**

The args array needs to carry seeker state machine data. We have two options:

**Option A (recommended): Extend `_navigationStateParams` to a general state params array.**

This is invasive. Instead:

**Option B: Add a new element to the args array at index [7].**

Modify the args array construction (line 150-182) to append:

```sqf
private _args = [_this,
            [   _shooter,
                [_target, _targetPos, _launchPos, vectorDirVisual vehicle _shooter, CBA_missionTime],
                _seekerType,
                _attackProfile,
                _lockMode,
                _laserInfo,
                _navigationType
            ],
            [
                _pitchRate,
                _yawRate,
                _bangBang,
                _stabilityCoefficient,
                _showTrail
            ],
            [
                getNumber ( _config >> "seekerAngle" ),
                getNumber ( _config >> "seekerAccuracy" ),
                getNumber ( _config >> "seekerMaxRange" ),
                getNumber ( _config >> "seekerMinRange" )
            ],
            [ diag_tickTime, [], [], _lastKnownPosState, _navigationParameters, [_initialYaw + (_yawRollPitch select 1), _initialRoll, _initialPitch + (_yawRollPitch select 2)]],
            [
                [0, 0, 0],
                [0, 0, 0],
                0,
                [0, 0, 0],
                [0, 0, 0]
            ],
            [0, _navigationStateData],
            [0, _seekerStateData]    // NEW: index [7] — [_currentSeekerState, _seekerStateData]
        ];
```

**Step 3: Call onFired for all seeker states (not just the initial seeker)**

Replace the single seeker onFired call (lines 184-188) with a loop that initialises ALL seeker states (same pattern as navigation states at lines 196-212):

```sqf
if (_seekerStates isEqualTo []) then {
    // No state machine — single seeker, existing behaviour
    private _onFiredFunc = getText (configFile >> QGVAR(SeekerTypes) >> _seekerType >> "onFired");
    TRACE_1("seeker on fired",_onFiredFunc);
    if (_onFiredFunc != "") then {
        _args call (missionNamespace getVariable _onFiredFunc);
    };
} else {
    // State machine — call onFired for each seeker state
    {
        private _stateSeekerType = _x select 1;
        private _onFiredFunc = getText (configFile >> QGVAR(SeekerTypes) >> _stateSeekerType >> "onFired");
        TRACE_2("seeker state on fired",_stateSeekerType,_onFiredFunc);
        if (_onFiredFunc != "") then {
            // Temporarily set _seekerType in launch params so onFired reads the right type
            _launchParams = _args select 1;
            _launchParams set [2, _stateSeekerType];

            // Save current seekerStateParams, swap in the state-specific one
            private _savedSeekerStateParams = (_args select 4) select 1;
            private _stateSeekerStateParams = [];
            (_args select 4) set [1, _stateSeekerStateParams];

            _args call (missionNamespace getVariable _onFiredFunc);

            // Store the initialised state params back into seekerStateData
            (_seekerStateData select _forEachIndex) set [2, _stateSeekerStateParams];

            // Restore
            (_args select 4) set [1, _savedSeekerStateParams];
        };
    } forEach _seekerStateData;

    // Restore initial seeker type
    (_args select 1) set [2, (_seekerStateData select 0) select 1];
    // Set initial seeker state params
    (_args select 4) set [1, +(_seekerStateData select 0 select 2)];
};
```

**Step 4: Verify build**

Run: `hemtt dev`
Expected: No errors. Existing missiles (no `seekerStates` config) should behave identically.

**Step 5: Commit**

```
feat(missileguidance): parse seekerStates config and initialise all seeker states at fire time
```

---

### Task 5: Evaluate Seeker State Machine in the PFH

**Files:**
- Modify: `addons/missileguidance/functions/fnc_guidancePFH.sqf`

Add seeker state transition logic, mirroring the navigation state machine at lines 55-68.

**Step 1: Destructure the new seeker state params**

At line 23, the args are destructured. Update to include the new index [7]:

Change:
```sqf
_args params ["_firedEH", "_launchParams", "_flightParams", "_seekerParams", "_stateParams", "_targetData", "_navigationStateParams"];
```

To:
```sqf
_args params ["_firedEH", "_launchParams", "_flightParams", "_seekerParams", "_stateParams", "_targetData", "_navigationStateParams", "_seekerStateParams"];
```

Then destructure `_seekerStateParams`:
```sqf
_seekerStateParams params [["_currentSeekerState", 0], ["_seekerStateData", []]];
```

**Note:** Using default values `[0]` and `[[]]` ensures backward compatibility — missiles without seeker states will have an empty array at index [7] (or the index won't exist, and params will use defaults).

**Step 2: Add seeker state machine evaluation BEFORE `doSeekerSearch`**

Insert before line 43 (`private _seekerTargetPos = ...`):

```sqf
// Evaluate seeker state machine (if configured)
if (_seekerStateData isNotEqualTo []) then {
    (_seekerStateData select _currentSeekerState) params ["_seekerTransitionCondition", "_stateSeekerType"];
    if (_seekerTransitionCondition != "") then {
        private _seekerTransition = ([_args, _timestep] call (missionNamespace getVariable [_seekerTransitionCondition, { false }]));
        if (_seekerTransition) then {
            private _previousSeekerState = _currentSeekerState;
            _currentSeekerState = _currentSeekerState + 1;
            _seekerStateParams set [0, _currentSeekerState];

            // Get new seeker type from the new state
            private _newSeekerType = (_seekerStateData select _currentSeekerState) select 1;
            TRACE_3("Seeker state transition",_previousSeekerState,_currentSeekerState,_newSeekerType);

            // Update launch params with new seeker type
            _launchParams set [2, _newSeekerType];

            // Swap seeker state params to the new state's initialised params
            private _newSeekerStateParamsData = +(_seekerStateData select _currentSeekerState select 2);
            _stateParams set [1, _newSeekerStateParamsData];

            // Reset last known position state for new seeker
            _lastKnownPosState set [1, [0, 0, 0]];
        };
    };
};
```

**Step 3: Verify build and backward compatibility**

Run: `hemtt dev`
Expected: No errors. Test with existing missiles (Hellfire, Javelin, etc.) — they should work identically since `_seekerStateData` will be empty.

**Step 4: Commit**

```
feat(missileguidance): evaluate seeker state machine transitions in guidance PFH
```

---

### Task 6: Add Debug Drawing for Seeker State

**Files:**
- Modify: `addons/missileguidance/functions/fnc_guidancePFH.sqf`

**Step 1: Extend the existing debug drawing**

In the debug block at line 80, add seeker state info:

```sqf
if (_seekerStateData isNotEqualTo []) then {
    private _seekerStateName = (_seekerStateData select _currentSeekerState) select 1;
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,1,1], _projectilePosAGL vectorAdd [0, 0, 3], 0.75, 0.75, 0, format ["Seeker: %1 [%2/%3]", _seekerStateName, _currentSeekerState + 1, count _seekerStateData], 1, 0.025, "TahomaB"];
};
```

Place this inside the `if (GVAR(debug_drawGuidanceInfo))` block near the other debug text.

**Step 2: Commit**

```
feat(missileguidance): add debug drawing for seeker state transitions
```

---

## Feature 3: Example Configs — Dual-Mode Hellfire & GPS→SALH Cruise Missile

### Task 7: Create a Dual-Mode Hellfire Config (SALH + MMW)

**Files:**
- Modify: `addons/missileguidance/CfgMissileTypesNato.hpp` (or create in your own addon's config)

This demonstrates pre-fire seeker selection. A Hellfire K (SALH) and Hellfire L (MMW) combined into one missile type that supports both.

**Step 1: Add a new missile type template**

```cpp
class GVAR(type_Hellfire_DualMode) : GVAR(type_Hellfire) {
    // Inherits all Hellfire settings

    // Override seeker to support both SALH and MMW
    defaultSeekerType = "SALH";
    seekerTypes[] = { "SALH", "MillimeterWaveRadar" };

    // MMW needs these from the AMRAAM/radar configs
    lockableTypes[] = {"Tank", "Car", "Ship", "LandVehicle"};
    activeRadarEngageDistance = 500;
};
```

**Step 2: Create a CfgAmmo entry that uses it**

This would typically go in your mod's config, not in ACE core. Example:

```cpp
class CfgAmmo {
    class ace_hellfire_AGM_114K;
    class my_hellfire_dualmode : ace_hellfire_AGM_114K {
        class ace_missileguidance : ace_missileguidance {
            enabled = 1;
            // All other values inherited from type_Hellfire_DualMode
            defaultSeekerType = "SALH";
            seekerTypes[] = { "SALH", "MillimeterWaveRadar" };
            lockableTypes[] = {"Tank", "Car", "Ship", "LandVehicle"};
        };
    };
};
```

**Step 3: Commit**

```
feat(missileguidance): add dual-mode Hellfire example config (SALH + MMW)
```

---

### Task 8: Create a GPS→SALH Cruise Missile Config with Seeker States

**Files:**
- Create: `addons/missileguidance/functions/fnc_cruiseMissile_seekerTransition.sqf` (transition condition function)
- Modify: `addons/missileguidance/CfgMissileTypesNato.hpp` (or your own addon's config)

This demonstrates mid-flight seeker switching. The cruise missile follows GPS waypoints, then at the terminal phase switches to SALH for precision laser guidance.

**Step 1: Create the transition condition function**

This function determines when to switch from GPS to SALH. It should fire when the cruise missile attack profile reaches STAGE_TERMINAL (or near the target).

```sqf
#include "..\script_component.hpp"
/*
 * Author: [yourname]
 * Transition condition for cruise missile seeker switch: GPS -> SALH.
 * Transitions when the cruise missile enters terminal phase
 * (attack profile state is STAGE_POPUP or STAGE_TERMINAL).
 *
 * Arguments:
 * 0: Guidance Arg Array <ARRAY>
 * 1: Timestep <NUMBER>
 *
 * Return Value:
 * Should transition <BOOL>
 *
 * Example:
 * [_args, 0.1] call ace_missileguidance_fnc_cruiseMissile_seekerTransition
 *
 * Public: No
 */

params ["_args"];
_args params ["_firedEH", "", "", "", "_stateParams"];
_firedEH params ["","","","","","","_projectile"];
_stateParams params ["", "", "_attackProfileStateParams"];

// cruise_missile_defines.hpp: STAGE_POPUP = 5, STAGE_TERMINAL = 6
private _stage = _attackProfileStateParams param [0, 0];

// Transition when entering popup or terminal phase
_stage >= 5
```

**Step 2: Register the function**

If using auto-prep from the functions folder, the file just needs to exist. Otherwise add to XEH_preInit:
```sqf
PREP(cruiseMissile_seekerTransition);
```

**Step 3: Update the CruiseMissile type config**

```cpp
class GVAR(type_CruiseMissile_LaserTerminal) : GVAR(type_CruiseMissile) {
    // Inherits all CruiseMissile settings

    // Now supports both GPS (cruise) and SALH (terminal)
    seekerTypes[] = { "GPS", "SALH" };

    seekLastTargetPos = 1;  // If laser lost during terminal, use last known pos

    class seekerStates {
        class cruise {
            transitionCondition = QFUNC(cruiseMissile_seekerTransition);
            seekerType = "GPS";
        };
        class terminal {
            transitionCondition = "";
            seekerType = "SALH";
        };
        states[] = {"cruise", "terminal"};
    };
};
```

**Step 4: Create a CfgAmmo entry that uses it**

```cpp
class CfgAmmo {
    // Inherit from whatever cruise missile ammo exists
    class my_cruise_missile_laser : my_cruise_missile_base {
        class ace_missileguidance : ace_missileguidance {
            enabled = 1;
            seekerTypes[] = { "GPS", "SALH" };
            seekLastTargetPos = 1;

            class seekerStates {
                class cruise {
                    transitionCondition = QFUNC(cruiseMissile_seekerTransition);
                    seekerType = "GPS";
                };
                class terminal {
                    transitionCondition = "";
                    seekerType = "SALH";
                };
                states[] = {"cruise", "terminal"};
            };
        };
    };
};
```

**Step 5: Commit**

```
feat(missileguidance): add GPS->SALH cruise missile example with seeker state machine
```

---

## Task 9: Backward Compatibility Verification

**Files:**
- No new files — testing only

**Step 1: Verify all existing missile types still work**

The changes must not break any existing missile. Key things to verify:

1. **Args array index [7]**: Missiles without `seekerStates` won't have this index. The `params` destructuring in the PFH uses default values `[["_currentSeekerState", 0], ["_seekerStateData", []]]`, so missing data results in empty state and no transitions. Verify this.

2. **onFired call path**: The new branching in `fnc_onFiredGetArgs` (`if _seekerStates isEqualTo []`) must preserve the original single-onFired path exactly.

3. **Test these missile types** (each has different seeker/nav/profile combinations):
   - Hellfire (SALH, navigation states, multiple attack profiles)
   - Javelin (Optic, navigation states, fire mode attack profiles)
   - Stinger/Sidewinder (IR seeker with onFired)
   - AMRAAM (DopplerRadar with onFired)
   - AGM-114L Longbow (MWR with onFired)
   - TOW/Milan (SACLOS wire guided)
   - JDAM/Paveway (GPS/SALH bombs)
   - Cruise Missile (GPS with cruise_missile attack profile)

**Step 2: Commit**

No code changes — this is a testing task only.

---

## Summary of All Changes

| File | Change | Task |
|------|--------|------|
| `functions/fnc_cycleSeekerType.sqf` | **NEW** — pre-fire seeker cycling | 1 |
| `functions/fnc_setupSeekerActions.sqf` | **NEW** — ACE interact actions for seeker selection | 3 |
| `functions/fnc_cruiseMissile_seekerTransition.sqf` | **NEW** — GPS→SALH transition condition | 8 |
| `XEH_postInit.sqf` | Add keybind + vehicle enter event handlers | 2, 3 |
| `stringtable.xml` | Add localisation keys | 2, 3 |
| `ACE_GuidanceConfig.hpp` | Fill in seeker type display names | 3 |
| `fnc_onFiredGetArgs.sqf` | Parse `seekerStates`, init all seeker state onFired handlers, add `[7]` to args | 4 |
| `fnc_guidancePFH.sqf` | Destructure `[7]`, evaluate seeker state transitions before doSeekerSearch, debug drawing | 5, 6 |
| `CfgMissileTypesNato.hpp` | Add `type_Hellfire_DualMode` and `type_CruiseMissile_LaserTerminal` examples | 7, 8 |

## Risks and Mitigations

1. **Args array extension**: Adding index [7] could break code that assumes a fixed array length. Mitigation: SQF `params` with defaults handles missing indices gracefully. Grep for any code that does `count _args` or accesses fixed indices.

2. **Seeker state params sharing**: When calling onFired for multiple seeker states, we temporarily swap `_stateParams[1]`. If an onFired function reads/writes other parts of `_stateParams`, there could be cross-contamination. Mitigation: Review all seeker onFired handlers (done above — they only touch `_seekerStateParams`).

3. **SALH laser code**: When switching to SALH mid-flight, the laser code comes from `_laserInfo` (set at launch from the shooter's `ace_laser_code` variable). This is already in the args and doesn't change. The SALH seeker reads it from `_launchParams[5]`. This should work without changes.

4. **GPS seeker state**: GPS stores its attack position in `_seekerStateParams[0]`. When transitioning FROM GPS, the GPS state data is preserved in `_seekerStateData[0][2]`. If you ever needed to transition BACK to GPS, the waypoint data would still be there.

5. **Performance**: The seeker state check adds one array access + one string comparison per frame for missiles with seeker states. This is negligible.
