---
layout: wiki
title: Modules
description: A list of all modules in ACE3 and all the settings that can be tweaked by them
group: missionmaker
order: 5
parent: wiki
---

## 1. ACE3

### 1.1 Advanced Ballistics
*Part of: ace_advanced_ballistics*

This module allows enabling and configuring advanced ballistic simulations.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Advanced Ballistics | Boolean | Enables Advanced Ballistics. | No
Enabled For Snipers | Boolean | Enables Advanced Ballistics for non local snipers (when using high power optics). | Yes
Enabled For Group Members | Boolean | Enables Advanced Ballistics for non local group members.| No
Enabled For Everyone | Boolean | Enables Advanced Ballistics for all non local players (enabling this feature may degrade performance during heavy firefights in multiplayer). | No
Disabled In FullAuto Mode | Boolean | Disables the Advanced Ballistics during full auto fire. | No
Enable Ammo Temperature Simulation | Boolean | Muzzle velocity varies with ammo temperature. | Yes
Enable Barrel Length Simulation | Boolean | Muzzle velocity varies with barrel length. | Yes
Enable Bullet Trace Effect | Boolean | Enables a bullet trace effect to high caliber bullets (only visible when looking through high power optics). | Yes
Simulation Interval | Number | Defines the interval between every calculation step. | 0.00
Simulation Radius | Number | Defines the radius around the player (in meters) at which Advanced Ballistics are applied to projectiles. | 3000

### 1.2 Allow Config Export
*Part of: ace_optionmenu*

This modules allows to export all current ACE3 settings from the ACE3 Option menu to the clipboard and RPT file.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Allow | Boolean | Enables the "export" button in the ACE3 Option menu. | Yes

### 1.3 BlueForceTracking
*Part of: ace_map*

When adding the "Blue Force Tracking" module to your mission it adds map markers to every group on the players side and refreshes them in certain configurable interval (in seconds). The module takes the group type into account and uses the proper NATO icon for each marker.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
BFT Enable | Boolean | Enable blue force tracking | No
Interval | Number | How often the markers should be refreshed (in seconds). | 1
Hide AI Groups | Boolean | Hide markers for "AI only" groups. | No

### 1.4 Captives settings
*Part of: ace_captives*

Controls the settings for cable ties and surrendering.
Very useful if you don't want your players to be able to restrict each others.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Can handcuff own side | Boolean | Determine if you are able to handcuff your own side or not. | Yes
Allow surrendering | Boolean | Determine if you are able to surrender or not when your weapon is holstered. | Yes
Require surrendering | Option | Require players to surrender before they can be arrested. | Surrendering only

### 1.5 Check PBOs
*Part of: ace_common*

If you are worried that players haven't updated ACE3 or other mods to the version you're using on the server, you can place the "Check PBOs" module on your map. You can choose one of three posible actions that are being executed when a player joins that has a wrong version of ACE3 or an other mod:

- Warn once
- Warn permanent
- Kick

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Action | Option | What to do with people who do not have the right PBOs. | Warn once
Check all addons | Boolean | Check all addons instead of only those of ACE3? | No

 **Whitelist**

You can make a whitelist of addons that don't have to be on the server. If you want to use the "Check all addons" option of this module and allow the usage of client side modifications like Blastcore or JSRS, you have to list them here.
The list must be in the following format: `["ADDON1","ADDON2",...]` where the addons are CfgPatches references to all PBOs of the optional mod. To figure these out, you can use the scripting command `activatedAddons` in the editor while those mods are enabled.

Example 1: @Blastcore-A3:<br>
```
["warfxpe","blastcore_vep"]
```

Example 2: @JSRS:<br>
```
[TBD]
```

Example 3: @JSRS + @Blastcore-A3:<br>
```
[TBD, "warfxpe","blastcore_vep"]
```

### 1.6 Explosive System
*Part of: ace_explosive*

The "Explosive System" module lets you tweak the settings for the new explosive system that ACE3 introduces.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Require specialists? | Boolean | Require explosive specialists to disable explosives. | No
Punish non-specialists? | Boolean | Increase the time it takes to complete actions for non-specialists. | Yes
Explode on defusal? | Boolean | Enables certain explosives to explode on defusal? | Yes

### 1.7 Friendly Fire Messages
*Part of: ace_respawn*

The "Friendly Fire Messages" module triggers a message when a player kills a friendly or civilian unit. This module isn't needed on servers with a low difficulty setting.

### 1.8 Hearing
*Part of: ace_hearing*

Placing this modules allows you to disable combat deafness usually triggered by loud explosions or heavy weapons in a players proximity.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Combat deafness | Boolean | Reduces the hearing ability as the player takes hearing damage. | Yes
Disable ear ringing | Option | | Do Not Force
Effect Zeus RC | Boolean | Allow zeus remote controlled units to be able to take hearing damage. | yes

### 1.9 Interaction System
*Part of: ace_interaction*

This module allows you to tweak if players should be able to use team management functions (e.g. "switch group", "become leader").

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enable Team Management | Boolean | Should players be allowed to use the Team Management Menu?. | Yes

### 1.10 LSD Vehicles
*Part of: ace_common*

Any vehicle linked to this module will become a seizure inducing machine of doom, no, really.

### 1.11 Make Unit Surrender
*Part of: ace_captives*

Syncing units to that module sets them in the captive state with their arms behind their back. Useful for e.g. hostage rescue missions.

### 1.12 Map
*Part of: ace_map*

ACE3 introduces a bit more realism for the vanilla Arma 3 map and how it behaves. Some of these settings can be toggled by this module.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Map illumination? | Boolean | Calculate dynamic map illumination based on light conditions? | Yes
Map flashlight glow? | Boolean | Add external glow to players using flashlight on map? | Yes
Map shake? | Boolean | Make map shake when walking? | Yes
Limit map zoom? | Boolean | Limit the amount of zoom available for the map? | No
Show cursor coordinates? | Boolean | Show the grid coordinates on the mouse pointer? | No

### 1.13 MicroDAGR Map Fill
*Part of: ace_microdagr*

Controls how much data is filled on the microDAGR items. Less data restricts the map view to show less on the minimap.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
MicroDAGR Map Fill | Option | How much map data is filled on MicroDAGR's. | "Full Satellite + Buildings"

### 1.14 MK6 Settings
*Part of: ace_mk6mortar*

ACE3 now includes the first iteration of getting a less arcady point and click mortar experience.
Placing this modules allows you to enable the increased realism in game.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Air Resistance | Boolean | For Player Shots, Model Air Resistance and Wind Effects. | No
Allow MK6 Computer | Boolean | Show the Computer and Rangefinder (these **NEED** to be removed if you enable air resistance). | No
Allow MK6 Compass | Boolean | Show the MK6 Digital Compass. | Yes
Use Ammunition Handling | Boolean | Removes magazines from mortars, requiring individual rounds to be loaded manually. Does not affect AI mortars. | No

### 1.15 Name Tags
*Part of: ace_nametags*

This module allows you to tweak the settings for player names tags.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Show player names | Option | Let you choose when nametags appears. | Do Not Force
layer Names View Distance | Number | Distance (in meters) at which player names are shown. | 5
Show name tags for AI? | Option | Show the name and rank tags for friendly AI units, or by default allows players to choose it on their own. | Do Not Force
Show crew info? | Option | Show vehicle crew info, or by default allows players to choose it on their own. | Do Not Force
Show for Vehicles? | Boolean | Show cursor NameTag for vehicle commander (only if client has name tags enabled). | No

### 1.16 Pointing settings
*Part of: ace_finger*

This module allows you to tweak settings for finger pointing such as if it's enabled or the distance at which people can see you pointing at something.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Pointing enabled | Boolean |  | Yes
Pointing Max Range | Number | Max range between players to show the pointing indicator (in meters) | 4

### 1.17 Rallypoint System
*Part of: ace_respawn*

This module enables Mission Makers to specifically enable units to move a rallypoint. Every unit that is synced with that module is able to move a rallypoint.

<div class="panel callout">
    <h5>Note:</h5>
    <p>It's important to mention that this doesn't work for player who join during a mission (JIP = Join in progress). That's something we can't change because that's the way Bohemia has implemented their module framework.</p>
</div>

To enable JIP players to move rally points have a look at [ACE3 Rallypoints](./mission-tools.html#1.-ace-rallypoints).

### 1.18 Respawn System
*Part of: ace_respawn*

The "Respawn System" module enables players to respawn with the gear they had before dying and to remove bodies of players after a configurable interval (in seconds).

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Save Gear? | Boolean | Respawn with the gear a player had just before his death. | No
Remove bodies? | Boolean | Remove player bodies after disconnect? | Yes

### 1.19 Sitting
*Part of: ace_sitting*

This module is used to turn sitting on.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enable sitting | Boolean | | Yes

### 1.20 Spectator
*Part of: ace_spectator*

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Unit filter | Option | Method of filtering spectatable units. | Playable Units
Side filter | Option | Method of filtering spectatable sides. | Player side
Camera modes | Option | Camera modes that can be used. | All
Vision modes | Option | Vision modes that can be used. | All

### 1.21 SwitchUnits System
*Part of: ace_switchunits*

The [SwitchUnits System](./mission-tools.html#ace-switchunits) enables players to control certain AI units on the map.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Switch To West? | Boolean | Allow switching to west units? | No
Switch To East? | Boolean | Allow switching to east units? | No
Switch To Independent? | Boolean | Allow switching to independent units? | No
Switch To Civilian? | Boolean | Allow switching to civilian units? | No
Enable Safe Zone? | Boolean | Enable a safe zone around enemy units? Players can't switch to units inside of the safe zone. |   Yes
Safe Zone Radius | Number | The safe zone around players from a different team (in meters). | 200

### 1.22 Vehicle Lock
*Part of: ace_vehiclelock*

These modules allow you to lock and unlock vehicles and their inventory using a key. Players don't receive a key automatically; for key names, see [Class names Wiki](http://ace3mod.com/wiki/missionmaker/class-names.html#vehicle-lock).

#### 1.22.1 Vehicle Key Assign
Sync with vehicles and players. Will handout custom keys to players for every synced vehicle. Only valid for objects present at mission start.
Example: `[bob, car1, true] call ACE_VehicleLock_fnc_addKeyForVehicle;` - will add a key to bob and program it to work only on car1

#### 1.22.2.1 Vehicle Lock Setup
Settings for lockpick strength and initial vehicle lock state. Removes ambiguous lock states.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Lock Vehicle Inventory? | Boolean | Locks the inventory of locked vehicles. | No
Vehicle Starting Lock State | Option | Set lock state for all vehicles (removes ambiguous lock states). | "As Is"
Default Lockpick Strength | Number | Default Time to lockpick (in seconds). | 10

#### 1.22.2.2 Vehicle setVariables
* `ACE_VehicleLock_lockSide` - SIDE: overrides a vehicle's side, allowing locking and unlocking using a different side's key. For example: Unlocking INDEP vehicles with a BLUFOR key.
* `ACE_vehicleLock_lockpickStrength` - NUMBER: seconds, determines how long lockpicking with take, overrides the value set in the module for a specific vehicle of the mission maker's choice.

### 1.23 View Distance Limiter
*Part of: ace_viewdistance*

This module allows disabling the ACE3 View Distance feature as well as setting a view distance limit.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enable ACE viewdistance | Boolean | Enables ACE viewdistance. | Yes
View Distance Limit | Number | Sets the limit for how high clients can raise their view distance (<= 10 000) | 10000

### 1.24 Weather
*Part of: ace_weather*

This module allows you to customize the weather settings.

<div class="panel callout">
    <h5>Note:</h5>
    <p>ACE3 Weather overrides weather settings (editor, mission settings) and automatically calculates wind, temperature and pressure according to map location, date, time of day and cloud coverage and allows the weather to evolve realistically as the simulation progresses. Weather synchronization occurs between all clients. <br>Adjustment of the weather is possible by modifying the <code>overcast</code> value (for example: <code>0.7</code> may result in intermittent rain).</p>
</div>

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Weather propagation | Boolean | Enables sever side weather propagation.(This is responsible for synchronizing weather between all clients. Disabling it is **NOT** recommended). | Yes
ACE3 Weather | Boolean | Overrides the default weather with ACE3 weather (map based)(This can be disabled without affecting the weather propagation above. Useful if you prefer changing weather settings manually). | Yes
Sync Rain | Boolean | Synchronizes rain. | Yes
Sync Wind | Boolean | Synchronizes wind. | Yes
Sync Misc | Boolean | Synchronizes lightnings, rainbow, fog, ... | Yes
Update Interval | Number | Defines the interval (seconds) between weather updates. | 60

### 1.25 Wind Deflection
*Part of: ace_winddeflection*

This module allows you to define when Wind Deflection is active.

<div class="panel callout">
    <h5>Note:</h5>
    <p>Wind Deflection is compatible with Advanced Ballistics and allows the following combinations:</p>
    <ul>
        <li>Only Wind Deflection</li>
        <li>Only Advanced Ballistics</li>
        <li>Combined Wind Deflection + Advanced Ballistics</li>
    </ul>
</div>

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Wind Deflection | Boolean | Enables Wind Deflection. | Yes
Vehicle Enabled | Boolean | Enables Wind Deflection for static/vehicle gunners. | Yes
Simulation Interval | Number | Defines the interval between every calculation step. | 0.05
Simulation Radius | Number | Defines the radius around the player (in meters) at which projectiles are wind deflected. | 3000

### 1.26 Zeus Settings
*Part of: ace_zeus*

This module provides control over vanilla aspects of Zeus.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Ascension Messages | Boolean | Display global pop-up messages when a player is assigned as Zeus. | No
Zeus Eagle | Boolean | Spawn an eagle that follows the Zeus camera. | No
Wind Sounds | Boolean | Play wind sounds when Zeus remote controls a unit. | No
Ordnance Warning | Boolean | Play a radio warning when Zeus uses ordnance. | No
Reveal Mines | Option | Reveal mines to allies and place map markers. | "Disabled"


## 2. ACE Logistics

### 2.1 Add Spare Parts
*Part of: ace_repair*

Add spare parts to one or multiple objects.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | List | List of Objects that will get spare parts added, separated by commas. |
Part | Option | Spare part. | Spare wheel
Amount | Number | Number of selected spare parts. | 1

### 2.2 Assign Engineer
*Part of: ace_repair*

Assign one or multiple units as engineer.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | List | List of unit names that will be classified as engineer, separated by commas. |
Is Engineer | Option | Select the engineering skill of the unit. | Engineer |

### 2.3 Assign Repair Facility
*Part of: ace_repair*

Assign one or multiple objects as repair facility.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | List | List of objects that will be classified as repair facility, separated by commas. |
Is repair facility | Boolean | Is the object classified as a repair facility? | Yes

### 2.4 Assign Repair Vehicle
*Part of: ace_repair*

Assign one or multiple vehicles as repair vehicle.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | List | List of vehicles that will be classified as repair vehicles, separated by commas. |
Is repair vehicle | Boolean | Is the vehicle classified as a repair vehicle? | Yes

### 2.5 Cargo Settings
*Part of: ace_cargo*

Configure the cargo module settings

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enable Cargo | Boolean | Enable the load in cargo module. | Yes

### 2.6 Repair Settings
*Part of: ace_repair*

This module allows to tweak all the repair settings used in ACE3.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Allow Repair | Option | Who can perform repair actions? | Engineer only
Allow Wheel | Option | Who can remove and replace wheels? | Anyone
Repair Threshold | Number | What is the maximum amount of damage that can be repaired with a toolkit (0 to 1) | 0.6
Repair Threshold | Number | What is the maximum amount of damage that can be repaired by an engineer (0 to 1) | 0.4
Remove toolkit on use | Boolean | Should the toolkit be removed on usage? | No
Full Repair Location | Option | At what location can a vehicle be fully repaired? | Repair Facility Only
Allow Full Repair | Option | Who can perform a full repair on a vehicle? | Repair Specialist Only
Adds Spare Parts | Boolean | Adds spare part to vehicles (requires Cargo component) | Yes
Wheel repair requirements | Option | Items required to remove / replace wheels. | None

### 2.7 Rearm Settings
*Part of: ace_rearm*

This module allows to tweak all the rearm settings used in ACE3.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Rearm Amount | Option | How fast should a vehicle be rearmed? | Entire Vehicle

### 2.8 Refuel Settings
*Part of: ace_refuel*

This module allows to tweak all the refuel settings used in ACE3.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Flow Rate | Number | How fast should a vehicle be refueled? | 10

## 3. ACE3 Medical
*Part of: ace_medical*

### 3.1 Advanced Medical Settings

This module allows you to change the default Advanced Medical Settings, when [3.3 Medical Settings](#medical-settings) is set to "Advanced".

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enabled for | Option | Select what units the advanced medical system will be enabled for. | Players only
Enable Advanced wounds | Boolean | Allow reopening of bandaged wounds? | No
Vehicle Crashes | Boolean | Do units take damage from a vehicle crash? | Yes
Allow PAK | Option | Who can use the PAK for full heal? | Medics only
Remove PAK on use | Boolean | Should the PAK be removed on usage? | Yes
Condition PAK | Option | When can the PAK be used? | Stable
Locations PAK | Option | Where can the PAK be used? | Vehicles & facility
Allow Surgical kit | Option | Who can use the Surgical Kit? | Medics only
Remove Surgical kit | Boolean | Should Surgical Kit be removed on usage? | Yes
Locations Surgical kit | Option | Where can the Surgical Kit be used? | Vehicles & facility
Condition Surgical Kit | Option | When can the Surgical Kit be used? | Anytime
Heal hitpoints | Boolean | Heal fully bandaged hitpoints. | No
Pain suppression | Boolean | Pain is only temporarily suppressed not removed. | Yes

### 3.2 Medical Menu

This module is used to limit the use of the medical menu.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Allow Medical Menu | Option | Allow clients to use the medical menu. | Enabled


### 3.3 Medical Settings

This module allows to tweak all the medical settings used in ACE3.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Medical Level | Option | What is the medical simulation level? | Basic
Medics setting | Option | What is the level of detail preferred for medics? | Basic
Enable Litter | Boolean | Enable litter being created upon treatment. | Yes
Life time of litter objects | Number | How long should litter objects stay? In seconds. -1 is forever. | 1800
Enable Screams | Boolean | Enable screaming by injured units. | Yes
Player Damage | Number | What is the damage a player can take before being killed? | 1
AI Damage | Number | What is the damage an AI can take before being killed? | 1
AI Unconsciousness | Option | Allow AI to go unconscious. | 50/50
Remote controlled AI | Boolean | Treats remote controlled units as AI not players? | Yes
Prevent instant death | Boolean | Have a unit move to unconscious instead of death. | No
Bleeding coefficient | Number | Coefficient to modify the bleeding speed. | 1
Pain coefficient | Number | Coefficient to modify the pain intensity. | 1
Sync status | Boolean | Keep unit status synced. (Recommended on). | Yes


### 3.4 Revive Settings

This modules allows a mission maker to limit the amount of revives for units in basic and advanced medical.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Enable Revive | Option | Enable a basic revive system. | disabled
Max Revive time | Number | Max amount of seconds a unit can spend in revive state | 120
Max Revive lives | Number | Max amount of lives a unit. 0 or -1 is disabled. | -1

### 3.5 Set Medic Class

Using this module you can define which unit class is defined as a medic / doctor.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | String | List of unit names that will be classified as medic, separated by commas. |
Is Medic | Boolean | Medics allow for more advanced treatment in case of Advanced Medic roles enabled. | Regular medic


### 3.6 Set Medical Facility

Defines an object as a medical facility. This allows for more advanced treatments. Can be synced with buildings and vehicles.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Is Medical Facility | Boolean | Registers an object as a medical facility. | Yes

### 3.7 Set Medical Vehicle

Defines an object as a medical facility. This allows for more advanced treatments. Can be synced with buildings and vehicles.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
List | String | List of vehicles that will be classified as medical vehicle, separated by commas. |
Is Medical Vehicle | Boolean | Whether or not the objects in the list will be a medical vehicle. | Yes

## 4. ACE3 Mission Modules
*Part of: ace_missionmodules*

### 4.1 Ambiance Sounds

Used for ambiance sounds loop (synced across MP).

This module randomizes the time when the sound file is played and the position where the sound file is played (If "Follow Players" is set to No).
`Minimal Distance` and `Maximal Distance` influence the position from where the sound file is played. Setting both values to 0 forces the module to play the sound from where it was placed in the editor.
`Minimal Delay` and `Maximal Delay` work in a similar fashion but are used to randomize when the sound file is played. Setting both values to 0 plays the sound from mission start.

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Sounds | String | Class names of the ambiance sounds played. Separated by ','. (Example: `radio_track_01, electricity_loop`)|
Minimal Distance | Number | Used for calculating a random position and sets the minimal distance between the players and the played sound file(s) (in meters) | 400
Maximum Distance | Number | Used for calculating a random position and sets the maximum distance between the players and the played sound file(s) (in meters) | 900
Minimal Delay | Number | Minimal delay (in seconds) between sounds played | 10
Maximum Delay | Number | Maximum delay (in seconds) between sounds played | 10
Follow Players | Boolean | Follow players. If set to false, loop will play sounds only nearby logic position. | No
Volume | Number | The volume of the sounds played. | 1

### 4.2 Slideshow
*Part of: ace_slideshow*

This module is the core of `ace_slideshow` for more informations about slideshow check [the mission-tools section](./mission-tools.html)

**Settings:**

Name | Type | Description | Default value
---- | ---- | ---- | ---- |
Objects | String | Object names (can also be synchronized objects) slide-show will be displayed on, separated by commas if multiple. |
Controllers | String | Controller object names, separated by commas if multiple. |
Images | String | List of images that will be used for the slide-show, separated by commas, with full path correctly formatted (eg. images\image.paa). |
Interaction names | String | List of names that will be used for interaction entries, separated by commas, in order of images. |
Slide Duration | Number | Duration of each slide (in seconds) (0 = automatic slides disabled) | 0
