/*
 * Author: KoffeinFlummi, Glowbal, commy2
 * Main HandleDamage EH function.
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Name Of Hit Selection <STRING>
 * 2: Amount Of Damage <NUMBER>
 * 3: Shooter <OBJECT>
 * 4: Projectile <OBJECT/STRING>
 * 5: HitPointIndex (-1 for structural) <NUMBER>
 *
 * Return Value:
 * Damage To Be Inflicted <NUMBER>
 *
 * Public: No
 */
// #define DEBUG_MODE_FULL
// #define CBA_DEBUG_SYNCHRONOUS
#include "script_component.hpp"

params ["_unit", "_selection", "_damage", "_shooter", "_projectile", "_hitPointIndex"];
TRACE_6("ACE_DEBUG: HandleDamage Called",_unit, _selection, _damage, _shooter, _projectile,_hitPointIndex);

// bug, apparently can fire for remote units in special cases
if !(local _unit) exitWith {
    TRACE_2("ACE_DEBUG: HandleDamage on remote unit!",_unit,isServer);
    nil
};

// bug, assumed fixed, @todo excessive testing, if nothing happens remove
if (typeName _projectile == "OBJECT") then {
    TRACE_3("ACE_DEBUG: HandleDamage found projectile instead of classname of ammo!",_unit,_projectile,typeOf _projectile);
    _projectile = typeOf _projectile;
};

// Exit now we disable damage, replaces "allowDamage false"
if !(_unit getVariable [QGVAR(allowDamage), true]) exitWith {
    TRACE_2("ACE_DEBUG: HandleDamage damage disabled.",_selection,_unit);
    if (_selection == "") then {
        damage _unit
    } else {
        _unit getHit _selection
    };
};

// If damage is in dummy hitpoints, "hands" and "legs", don't change anything
if (_selection == "hands") exitWith {_unit getHit "hands"};
if (_selection == "legs") exitWith {_unit getHit "legs"};
if (_selection == "arms") exitWith {_unit getHit "arms"};

// Deal with the new hitpoint and selection names introduced with Arma v1.50 and later.
// This will convert new selection names into selection names that the medical system understands
// TODO This should be cleaned up when we revisit the medical system at a later stage
// and instead we should deal with the new hitpoints directly
_selection = [_unit, _selection, _hitPointIndex] call FUNC(translateSelections);


private _unitProjectiles = _unit getVariable [QGVAR(projectiles), []];
if (!(_projectile in _unitProjectiles)) then {
    if (_unitProjectiles isEqualTo []) then {
        diag_log text format ["%1 - Adding waitUntilAndExecute", diag_frameno];
        [{
            params ["_unit"];
            private _unitProjectiles = _unit getVariable [QGVAR(projectiles), []];
            private _removed = []; //todo 1.56 filter/select shit
            {
                private _projectile = _x;
                (_unit getVariable [format [QGVAR(projectile_%1), _projectile], [-1, [0,0,0,0,0,0]]]) params ["_firstHitTime", "_cachedDamages"];
                if (diag_frameno > (_firstHitTime + 3)) then {
                    diag_log text format ["%1 - processing %2 - %3", diag_frameno, _projectile, _cachedDamages];
                    _removed pushBack _x;
                    {
                        if (_x > 0) then {
                            diag_log text format ["Sel Dam Event %1", [_unit, GVAR(Selections) select _forEachIndex, _x, _projectile]];
                            ["medical_selectionDamage", [_unit, GVAR(Selections) select _forEachIndex, _x, _projectile]] call EFUNC(common,localEvent);
                        };
                    } forEach _cachedDamages;
                };
            } forEach _unitProjectiles;

            _unitProjectiles = _unitProjectiles - _removed;
            _unit setVariable [QGVAR(projectiles), _unitProjectiles];

            (_unitProjectiles isEqualTo [])
        }, {
            diag_log text format ["%1 - Removing waitUntilAndExecute", diag_frameno];
        }, [_unit]] call EFUNC(common,waitUntilAndExecute);
    };
    _unit setVariable [format [QGVAR(projectile_%1), _projectile], [diag_frameno, [0,0,0,0,0,0]]];
    _unitProjectiles pushBack _projectile;
    _unit setVariable [QGVAR(projectiles), _unitProjectiles];
};
(_unit getVariable [format [QGVAR(projectile_%1), _projectile], [-1, [0,0,0,0,0,0]]]) params ["_firstHitTime", "_cachedDamages"];


private ["_damageReturn", "_newDamage", "_index"];

// apply damage scripted
if (_selection == "") then {
    _damageReturn = _damage;
    _newDamage = _damage - damage _unit;

    scopeName "findDamageSource";

    // check for fall damage. this triggers twice, but seems to happen on the same frame. shouldn't fall twice in a few frames anyway. tested at 7FPS on local host MP
    if (animationState _unit select [0,4] == "afal") then {
        private _cachedLastFallDamageFrame = _unit getVariable [QGVAR(cachedLastFallDamageFrame), -1];

        if (diag_frameno != _cachedLastFallDamageFrame) then {
            ["medical_fallDamage", [_unit, _newDamage]] call EFUNC(common,localEvent);
            _unit setVariable [QGVAR(cachedLastFallDamageFrame), diag_frameno];
        };
        _damageReturn = damage _unit;
        breakOut "findDamageSource";
    };

    // check for drowning damage. Pretty relyable damage output. triggers only once.
    if (getOxygenRemaining _unit < 0.5) then {
        // typical drowning damage
        if (_newDamage == 0.005) then {
            ["medical_drowningDamage", [_unit, _newDamage]] call EFUNC(common,localEvent);
            _damageReturn = damage _unit - 0.005; // engine applies damage before hd call. subtract again here.
            breakOut "findDamageSource";
        };

        // suffocated under water might use atypical new damage (mostly 1.005)
        if (getOxygenRemaining _unit == 0) then {
            ["medical_drowningDamage", [_unit, _newDamage min 1]] call EFUNC(common,localEvent);
            _damageReturn = damage _unit; // you will die regardless of hd return value
            breakOut "findDamageSource";
        };
    };

    // check for misc. damage. Probably collision.
    if ((_projectile == "") && {_newDamage > 0}) then {
        private _cachedLastCollisionDamageFrame = _unit getVariable [QGVAR(cachedLastFallDamageFrame), -1];

        // collision only happens once. engine ignores all further calls on that frame as well
        if (_cachedLastCollisionDamageFrame != diag_frameno) then {
            _unit setVariable [QGVAR(cachedLastFallDamageFrame), diag_frameno];
            _unit setVariable [QGVAR(cachedLastCollisionDamage), 0];

            ["medical_collisionDamage", [_unit, _newDamage max (_unit getVariable [QGVAR(cachedLastCollisionDamage), 0])]] call EFUNC(common,localEvent);

            _damageReturn = damage _unit - _newDamage;
            breakOut "findDamageSource";
        };
        _damageReturn = damage _unit;
    };
} else {
    // selections are done scripted. return same value to change nothing.
    _damageReturn = _unit getHitIndex _hitPointIndex;
    _newDamage = _damage - _damageReturn; // _damageReturn because it saves one getHit call

    if (_newDamage <= 0) exitWith {
        if (_newDamage < 0) then {
            diag_log text format ["ERROR: Negative Damage - %1", _newDamage];
        };
    };

    private _selectionIndex = GVAR(SELECTIONS) find _selection;

    // a selection we care for was hit. now save the new damage to apply it by a later structural damage call
    if (_selectionIndex != -1) then {
        (_cachedDamages call CBA_fnc_findMax) params ["_max", "_maxIndex"];
        if (_newDamage > _max) then {
            _cachedDamages set [_maxIndex, 0];
            _cachedDamages set [_selectionIndex, _newDamage];
        };
    };

    // use this to detect collision damage.
    if (_projectile == "") then {
        _unit setVariable [QGVAR(cachedLastCollisionDamage), _newDamage max (_unit getVariable [QGVAR(cachedLastCollisionDamage), 0])];
    };
};

diag_log text format ["%1-HD %2 Retrun %3", diag_frameno, _this, _damageReturn];

_damageReturn
