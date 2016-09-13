//fnc_doSpall.sqf
#include "script_component.hpp"
// ACE_player sideChat "WAAAAAAAAAAAAAAAAAAAAA";

params ["_hitData"];
private _initialData = GVAR(spallHPData) select (_hitData select 0);
private _hpData = (_hitData select 1) select (_this select 1);

_hpData params ["_object"];
_object removeEventHandler ["hitPart", _initialData select 0];
private _foundObjects = _initialData select 7;
private _index = _foundObjects find _object;
if(_index != -1) then {
    _foundObjects set[_index, nil];
};

_initialData params ["", "_object", "_roundType", "_round"];

private _caliber = getNumber(configFile >> "CfgAmmo" >> _roundType >> "caliber");
private _explosive = getNumber(configFile >> "CfgAmmo" >> _roundType >> "explosive");
private _idh = getNumber(configFile >> "CfgAmmo" >> _roundType >> "indirectHitRange");

private _alive = true;
if(!alive _round && (_initialData select 6) isEqualTo 1) then {
    _alive = false;
};

if(_alive || {_caliber >= 2.5} || {(_explosive > 0 && {_idh >= 1})}) then {
    // ACE_player sideChat format["BBBB"];
    private _exit = false;
    private _vm = 1;
    private _velocity = _initialData select 5;

    private _oldVelocity = vectorMagnitude _velocity;
    private _curVelocity = vectorMagnitude (velocity _round);

    if(alive _round) then {
        private _diff = _velocity vectorDiff (velocity _round);
        private _polar = _diff call CBA_fnc_vect2polar;
        // ACE_player sideChat format["polar: %1", _polar];
        if((abs(_polar select 1) > 45 || abs(_polar select 2) > 45)) then {
            if(_caliber < 2.5) then {
                // ACE_player sideChat format["exit!"];
                _exit = true;
            } else {
                _vm = 1-(_curVelocity/_oldVelocity);
            };
        };
    };
    if(!_exit) then {
        private _unitDir = vectorNormalized _velocity;
        private _pos = _hpData select 3;
        private _spallPos = nil;
        for "_i" from 0 to 100 do {
            private _pos1 = _pos vectorAdd (_unitDir vectorMultiply (0.01 * _i));
            private _pos2 = _pos vectorAdd (_unitDir vectorMultiply (0.01 * (_i + 1)));
            // _blah = [_object, "FIRE"] intersect [_object worldToModel (ASLtoATL _pos1), _object worldToModel (ASLtoATL _pos2)];
            // diag_log text format["b: %1", _blah];

            // _data = [nil, nil, nil, 1, [[ASLtoATL _pos1, 1], [ASLtoATL _pos2, 1]]];
            // NOU_TRACES set[(count NOU_TRACES), _data];

            if(!lineIntersects [_pos1, _pos2]) exitWith {
                // ACE_player sideChat format["FOUND!"];
                _spallPos = _pos2;
            };
        };
        if(!isNil "_spallPos") then {
            private _spallPolar = _velocity call CBA_fnc_vect2polar;

            if(_explosive > 0) then {
                // ACE_player sideChat format["EXPLOSIVE!"];
                private _warn = false;
                private _c = getNumber(configFile >> "CfgAmmo" >> _roundType >> QGVAR(CHARGE));
                if(_c == 0) then { _c = 1; _warn = true;};
                private _m = getNumber(configFile >> "CfgAmmo" >> _roundType >> QGVAR(METAL));
                if(_m == 0) then { _m = 2; _warn = true;};
                private _k = getNumber(configFile >> "CfgAmmo" >> _roundType >> QGVAR(GURNEY_K));
                if(_k == 0) then { _k = 1/2; _warn = true;};
                private _gC = getNumber(configFile >> "CfgAmmo" >> _roundType >> QGVAR(GURNEY_C));
                if(_gC == 0) then { _gC = 2440; _warn = true;};

                if(_warn) then {
                    ACE_LOGWARNING_1("Ammo class %1 lacks proper explosive properties definitions for frag!",_roundType); //TODO: turn this off when we get closer to release
                };

                private _fragPower = (((_m/_c)+_k)^-(1/2))*_gC;
                _spallPolar set[0, _fragPower*0.66];
            };

            private _fragTypes = [
                QGVAR(spall_small), QGVAR(spall_small), QGVAR(spall_small),
                QGVAR(spall_small),QGVAR(spall_medium),QGVAR(spall_medium),QGVAR(spall_medium),
                QGVAR(spall_medium), QGVAR(spall_large), QGVAR(spall_large), QGVAR(spall_huge),
                QGVAR(spall_huge)

            ];

            // diag_log text format["SPALL POWER: %1", _spallPolar select 0];
            private _spread = 15+(random 25);
            private _spallCount = 5+(random 10);
            for "_i" from 1 to _spallCount do {
                private _elev = ((_spallPolar select 2)-_spread)+(random (_spread*2));
                private _dir = ((_spallPolar select 1)-_spread)+(random (_spread*2));
                if(abs _elev > 90) then {
                    _dir = _dir + 180;
                };
                _dir = _dir % 360;
                private _vel = (_spallPolar select 0)*0.33*_vm;
                _vel = (_vel-(_vel*0.25))+(random (_vel*0.5));

                private _spallFragVect = [_vel, _dir, _elev] call CBA_fnc_polar2vect;
                private _fragType = round (random ((count _fragTypes)-1));
                private _fragment = (_fragTypes select _fragType) createVehicleLocal [0,0,10000];
                _fragment setPosASL _spallPos;
                _fragment setVelocity _spallFragVect;

                if(GVAR(traceFrags)) then {
                    [ACE_player, _fragment, [1,0.5,0,1]] call FUNC(addTrack);
                };
            };
            _spread = 5+(random 5);
            _spallCount = 3+(random 5);
            for "_i" from 1 to _spallCount do {
                private _elev = ((_spallPolar select 2)-_spread)+(random (_spread*2));
                private _dir = ((_spallPolar select 1)-_spread)+(random (_spread*2));
                if(abs _elev > 90) then {
                    _dir = _dir + 180;
                };
                _dir = _dir % 360;
                private _vel = (_spallPolar select 0)*0.55*_vm;
                _vel = (_vel-(_vel*0.25))+(random (_vel*0.5));

                private _spallFragVect = [_vel, _dir, _elev] call CBA_fnc_polar2vect;
                private _fragType = round (random ((count _fragTypes)-1));
                private _fragment = (_fragTypes select _fragType) createVehicleLocal [0,0,10000];
                _fragment setPosASL _spallPos;
                _fragment setVelocity _spallFragVect;

                if(GVAR(traceFrags)) then {
                    [ACE_player, _fragment, [1,0,0,1]] call FUNC(addTrack);
                };
            };
        };
    };
};
