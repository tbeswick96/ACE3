/*
 * Author: PabstMirror
 *
 *
 * Arguments:
 * 0: Target <OBJECT>
 *
 * Return Value:
 * Can Be Disarmed <BOOL>
 *
 * Example:
 * [cursorTarget] call ace_disarming_fnc_canBeDisarmed
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_args", "_pfhId"];
_args params ["_lastUpdateTime", "_nextMpSync"];

if ((isNull ACE_player) || {!alive ACE_player}) exitWith {
    [] call FUNC(showOverlay);
};

_deltaTime = ACE_time - _lastUpdateTime;
_args set [0, ACE_time];

local _drinkStatus = ACE_player getVariable [QGVAR(thirstStatus), 100];
local _foodStatus = ACE_player getVariable [QGVAR(hungerStatus), 100];

local _decentWater = _deltaTime / (36.0 * GVAR(timeWithoutWater));
local _decentFood = _deltaTime / (36.0 * GVAR(timeWithoutFood));

local _absSpeed = vectorMagnitude (velocity ACE_player);

// TODO add in weight calculation and effect
// If _unit is inside a vehicle, adjust waterlevels
if (((vehicle ACE_player) == ACE_player) && {_absSpeed > 1} && {((getPos ACE_player) select 2) < 10}) then {
    _decentWater = _decentWater + (_absSpeed / 400);
    _decentFood = _decentFood + (_absSpeed / 1200);
};

// Decrease both food and drink status based upon the decent rate
_drinkStatus = (_drinkStatus - _decentWater) max 0;
_foodStatus = (_foodStatus - _decentFood) max 0;

// Check if we want to do a new sync across MP for the ACE_player
local _doSync = false;
if (ACE_time > _nextMpSync) then {
    _doSync = true;
    _args set [1, (ACE_time + 60)];
};

// Store the hunger and thirst values
ACE_player setVariable [QGVAR(thirstStatus), _drinkStatus, _doSync];
ACE_player setVariable [QGVAR(hungerStatus), _foodStatus, _doSync];

// Update UI
[] call FUNC(showOverlay);

// Low hunger or thirst consequences
// If the unit runs out of either the drinking of food status, kill the unit
if (_drinkStatus < 1 || _foodStatus < 1) then {
    if (random(1) > 0.2) then {
        if (isClass (configFile >> "CfgPatches" >> "ACE_Medical")) then {
            [ACE_player] call EFUNC(medical,setDead);
        } else {
            ACE_player setDamage 1;
        };
    };
};

// No point continueing if the unit is not awake or alive. Below are all animation consequounces
if !([ACE_player] call EFUNC(common,isAwake)) exitwith {};

if ((_drinkStatus < 25) || {_foodStatus < 25}) then {
    if (speed ACE_player > 12 && vehicle ACE_player == ACE_player && {random(1) >= 0.3}) then {
        [ACE_player, "amovppnemstpsraswrfldnon", 2] call EFUNC(common,doAnimation);
    };
};

if ((_drinkStatus < 20) || {_foodStatus < 20}) then {
    if (random(1) > 0.8) then {
        [ACE_player, true] call EFUNC(medical,setUnconscious);
    };
};

local _animState = animationState ACE_player;
local _animStateChars = toArray _animState;
local _animP = toString [_animStateChars select 5,_animStateChars select 6,_aniMStateChars select 7];

if (_drinkStatus < 7 || _foodStatus < 7) then {
    if (speed ACE_player > 1 && vehicle ACE_player == ACE_player && (_animP != "pne")) then {
        [ACE_player, "amovppnemstpsraswrfldnon", 2] call EFUNC(common,doAnimation);
    };
};
