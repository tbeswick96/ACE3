/*
 * Author: Ruthberg
 * Calculates the range card data
 *
 * Arguments:
 * 0: Scope base angle <NUMBER>
 * 1: Bullet mass <NUMBER>
 * 2: Bore height <NUMBER>
 * 3: air friction <NUMBER>
 * 4: muzzle velocity <NUMBER>
 * 5: temperature <NUMBER>
 * 6: barometric pressure <NUMBER>
 * 7: relative humidity <NUMBER>
 * 8: simulation steps <NUMBER>
 * 9: wind speed <ARRAY>
 * 10: wind direction <NUMBER>
 * 11: inclination angle <NUMBER>
 * 12: target speed <NUMBER>
 * 13: target range <NUMBER>
 * 14: ballistic coefficient <NUMBER>
 * 15: drag model <NUMBER>
 * 16: atmosphere model <STRING>
 * 17: Store range card data? <BOOL>
 * 18: Stability factor <NUMBER>
 * 19: Twist Direction <NUMBER>
 * 20: Latitude <NUMBER>
 * 21: Direction of Fire <NUMBER>
 * 22: Range Card Slot <NUMBER>
 * 23: Use advanced ballistics config? <BOOL>
 *
 * Return Value:
 * 0: Elevation (MOA) <NUMBER>
 * 1: Windage (MOA) <ARRAY>
 * 2: Lead (MOA) <NUMBER>
 * 3: Time of fligth (SECONDS) <NUMBER>
 * 4: Remaining velocity (m/s) <NUMBER>
 * 5: Remaining kinetic energy (ft·lb) <NUMBER>
 * 6: Vertical coriolis drift (MOA) <NUMBER>
 * 7: Horizontal coriolis drift (MOA) <NUMBER>
 * 8: Spin drift (MOA) <NUMBER>
 *
 * Example:
 * call ace_rangecard_fnc_calculateSolution
 *
 * Public: No
 */
#include "script_component.hpp"
params [
    "_scopeBaseAngle", "_bulletMass", "_boreHeight", "_airFriction", "_muzzleVelocity",
    "_temperature", "_barometricPressure", "_relativeHumidity", "_simSteps", "_windSpeed",
    "_windDirection", "_inclinationAngle", "_targetSpeed", "_targetRange", "_bc", "_dragModel",
    "_atmosphereModel", "_storeRangeCardData", "_stabilityFactor", "_twistDirection", "_latitude",
    "_directionOfFire", "_rangeCardSlot", "_useABConfig"
];
_windSpeed params ["_windSpeed1", "_windSpeed2"];

if (_storeRangeCardData) then {
    GVAR(rangeCardDataMVs) set [_rangeCardSlot, format[" %1", round(_muzzleVelocity)]];
};

private ["_bulletPos", "_bulletVelocity", "_bulletAccel", "_bulletSpeed", "_gravity", "_deltaT", "_speedOfSound"];
_bulletPos = [0, 0, 0];
_bulletVelocity = [0, 0, 0];
_bulletAccel = [0, 0, 0];
_bulletSpeed = 0;
_gravity = [0, sin(_scopeBaseAngle + _inclinationAngle) * -9.80665, cos(_scopeBaseAngle + _inclinationAngle) * -9.80665];
_deltaT = 1 / _simSteps;
_speedOfSound = 0;
if (missionNamespace getVariable [QEGVAR(advanced_ballistics,enabled), false]) then {
    _speedOfSound = _temperature call EFUNC(weather,calculateSpeedOfSound);
};

private ["_elevation", "_windage1", "_windage2", "_lead", "_TOF", "_trueVelocity", "_trueSpeed", "_kineticEnergy", "_verticalCoriolis", "_verticalDeflection", "_horizontalCoriolis", "_horizontalDeflection", "_spinDrift", "_spinDeflection"];
_elevation = 0;
_windage1 = 0;
_windage2 = 0;
_lead = 0;
_TOF = 0;
_trueVelocity = [0, 0, 0];
_trueSpeed = 0;
_verticalCoriolis = 0;
_verticalDeflection = 0;
_horizontalCoriolis = 0;
_horizontalDeflection = 0;
_spinDrift = 0;
_spinDeflection = 0;

private ["_n", "_range"];
_n = 0;
_range = 0;

private ["_wind1", "_wind2", "_windDrift"];
_wind1 = [cos(270 - _windDirection * 30) * _windSpeed1, sin(270 - _windDirection * 30) * _windSpeed1, 0];
_wind2 = [cos(270 - _windDirection * 30) * _windSpeed2, sin(270 - _windDirection * 30) * _windSpeed2, 0];
_windDrift = 0;
if (_useABConfig) then {
    _bc = [_bc, _temperature, _barometricPressure, _relativeHumidity, _atmosphereModel] call EFUNC(advanced_ballistics,calculateAtmosphericCorrection);
};

private ["_airFrictionCoef", "_airDensity"];
_airFrictionCoef = 1;
if (!_useABConfig && (missionNamespace getVariable [QEGVAR(advanced_ballistics,enabled), false])) then {
    _airDensity = [_temperature, _barometricPressure, _relativeHumidity] call EFUNC(weather,calculateAirDensity);
    _airFrictionCoef = _airDensity / 1.22498;
};

private ["_speedTotal", "_stepsTotal", "_speedAverage"];
_speedTotal = 0;
_stepsTotal = 0;
_speedAverage = 0;

_bulletPos set [0, 0];
_bulletPos set [1, 0];
_bulletPos set [2, -(_boreHeight / 100)];

_bulletVelocity set [0, 0];
_bulletVelocity set [1, Cos(_scopeBaseAngle) * _muzzleVelocity];
_bulletVelocity set [2, Sin(_scopeBaseAngle) * _muzzleVelocity];

while {_TOF < 6 && (_bulletPos select 1) < _targetRange} do {
    _bulletSpeed = vectorMagnitude _bulletVelocity;

    _speedTotal = _speedTotal + _bulletSpeed;
    _stepsTotal = _stepsTotal + 1;
    _speedAverage = (_speedTotal / _stepsTotal);

    if (_speedAverage > 450 && _bulletSpeed < _speedOfSound) exitWith {};
    if (atan((_bulletPos select 2) / (abs(_bulletPos select 1) + 1)) < -2.254) exitWith {};

    _trueVelocity = _bulletVelocity vectorDiff _wind1;
    _trueSpeed = vectorMagnitude _trueVelocity;

    if (_useABConfig) then {
        private _drag = if (missionNamespace getVariable [QEGVAR(advanced_ballistics,extensionAvailable), false]) then {
            parseNumber(("ace_advanced_ballistics" callExtension format["retard:%1:%2:%3", _dragModel, _bc, _trueSpeed]))
        } else {
            ([_dragModel, _bc, _trueSpeed] call EFUNC(advanced_ballistics,calculateRetardation))
        };
        _bulletAccel = (vectorNormalized _trueVelocity) vectorMultiply (-1 * _drag);
    } else {
        _bulletAccel = _trueVelocity vectorMultiply (_trueSpeed * _airFriction * _airFrictionCoef);
    };

    _bulletAccel = _bulletAccel vectorAdd _gravity;

    _bulletVelocity = _bulletVelocity vectorAdd (_bulletAccel vectorMultiply _deltaT);
    _bulletPos = _bulletPos vectorAdd (_bulletVelocity vectorMultiply _deltaT);

    _TOF = _TOF + _deltaT;

    if (_storeRangeCardData) then {
        _range = GVAR(rangeCardStartRange) + _n * GVAR(rangeCardIncrement);
        if ((_bulletPos select 1) >= _range && _range <= GVAR(rangeCardEndRange)) then {
            if ((_bulletPos select 1) > 0) then {
                _elevation = - atan((_bulletPos select 2) / (_bulletPos select 1));
                _windage1 = - atan((_bulletPos select 0) / (_bulletPos select 1));
            };
            if (_range != 0) then {
                _lead = (_targetSpeed * _TOF) / (Tan(3.38 / 60) * _range);
            };
            private ["_elevationString", "_windageString", "_leadString"];
            _elevationString = Str(round(-_elevation * 60 / 3.38 * 10) / 10);
            if (_elevationString == "0") then {
                _elevationString = "-0.0";
            };
            if (_elevationString find "." == -1) then {
                _elevationString = _elevationString + ".0";
            };
            _windageString = Str(round(_windage1 * 60 / 3.38 * 10) / 10);
            if (_windageString find "." == -1) then {
                _windageString = _windageString + ".0";
            };
            _leadString = Str(round(_lead * 10) / 10);
            if (_leadString find "." == -1) then {
                _leadString = _leadString + ".0";
            };
            (GVAR(rangeCardDataElevation) select _rangeCardSlot) set [_n, _elevationString];
            (GVAR(rangeCardDataWindage) select _rangeCardSlot) set [_n, _windageString];
            (GVAR(rangeCardDataLead) select _rangeCardSlot) set [_n, _leadString];
            _n = _n + 1;
        };
    };
};

if ((_bulletPos select 1) > 0) then {
    _elevation = - atan((_bulletPos select 2) / (_bulletPos select 1));
    _windage1 = - atan((_bulletPos select 0) / (_bulletPos select 1));
    _windDrift = (_wind2 select 0) * (_TOF - _targetRange / _muzzleVelocity);
    _windage2 = - atan(_windDrift / (_bulletPos select 1));
};

if (_targetRange != 0) then {
    _lead = (_targetSpeed * _TOF) / (Tan(3.38 / 60) * _targetRange);
};

_kineticEnergy = 0.5 * (_bulletMass / 1000 * (_bulletSpeed ^ 2));
_kineticEnergy = _kineticEnergy * 0.737562149;

[_elevation * 60, [_windage1 * 60, _windage2 * 60], _lead, _TOF, _bulletSpeed, _kineticEnergy, _verticalCoriolis * 60, _horizontalCoriolis * 60, _spinDrift * 60]
