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

EXPLODE_2_PVT((_this select 0),_lastTime,_nextSync);

if ((isNull ACE_player) || {!alive ACE_player}) exitWith {
    [] call FUNC(showOverlay);
};

_deltaTime = ACE_time - _lastTime;
(_this select 0) set [0, ACE_time];

_drinkStatus = ACE_player getVariable [QGVAR(thirstStatus), 100];
_foodStatus = ACE_player getVariable [QGVAR(hungerStatus), 100];

_decentWater = _deltaTime / (36.0 * GVAR(timeWithoutWater));
_decentFood = _deltaTime / (36.0 * GVAR(timeWithoutFood));

_absSpeed = vectorMagnitude (velocity _player);

// TODO add in weight calculation and effect
// If _unit is inside a vehicle, adjust waterlevels
if (((vehicle ACE_player) == ACE_player) && {_absSpeed > 1} && {((getPos ACE_player) select 2) < 10}) then {
    _decentWater = _decentWater + (_absSpeed / 400);
    _decentFood = _decentFood + (_absSpeed / 1200);
};

_drinkStatus = (_drinkStatus - _decentWater) max 0;
_foodStatus = (_foodStatus - _decentFood) max 0;

diag_log text format ["Tick - drink%1 food %2, %3", _drinkStatus, _foodStatus, [_decentWater, _decentFood]];
systemChat format ["Tick - drink%1 food %2, %3", _drinkStatus, _foodStatus, [_decentWater, _decentFood]];

_doSync = false;
if (ACE_time > _nextSync) then {
    _doSync = true;
    (_this select 0) set [1, (ACE_time + 60)];
};

ACE_player setVariable [QGVAR(thirstStatus), _drinkStatus, _doSync];
ACE_player setVariable [QGVAR(hungerStatus), _foodStatus, _doSync];

[] call FUNC(showOverlay);

//Apply thirst/hunger effects:



if ((_drinkStatus < 25) || {_foodStatus < 25}) then {
    if (speed _unit > 12 && vehicle _unit == _unit) then {
        _unit playMove "amovppnemstpsraswrfldnon";
    };
};

if ((_drinkStatus < 20) || {_foodStatus < 20}) then {
    if (random(1) > 0.8) then {
        // [_unit] call cse_fnc_setUnconsciousState;
    };
};

_animState = animationState _unit;
_animStateChars = toArray _animState;
_animP = toString [_animStateChars select 5,_animStateChars select 6,_aniMStateChars select 7];


if (_drinkStatus < 7 || _foodStatus < 7) then {
    if (speed _unit > 1 && vehicle _unit == _unit && (_animP != "pne")) then {
        // _unit playMove "amovppnemstpsraswrfldnon";
    };
};

if (_drinkStatus < 1 || _foodStatus < 1) then {
    if (random(1) > 0.2) then {
        // [_unit] call cse_fnc_setDead;
    };
};
