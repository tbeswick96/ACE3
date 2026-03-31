#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Terrain-following altitude computer for cruise missile guidance.
 *
 * Samples terrain along the missile's predicted curved flight path and returns
 * the maximum (terrain + cruiseAlt) across the lookahead window.
 *
 * The path curves from the current velocity direction toward the aim direction
 * at the missile's yaw rate, producing an arc that matches what the missile
 * will actually fly. Once the turn completes, sampling continues straight.
 *
 * Arguments:
 * 0: Projectile Position ASL <ARRAY>
 * 1: Current Velocity Direction (normalized) <ARRAY>
 * 2: Aim Direction (normalized) <ARRAY> - where guidance wants the missile to go
 * 3: Yaw Rate (degrees/second) <NUMBER>
 * 4: Pitch Rate (degrees/second) <NUMBER>
 * 5: Cruise Altitude AGL <NUMBER>
 * 6: Current Speed (m/s) <NUMBER>
 *
 * Return Value:
 * Desired Altitude ASL <NUMBER>
 *
 * Example:
 * [getPosASL _proj, _velDirection, _aimDirection, _yawRate, _pitchRate, 50, speed _proj] call ace_missile_cruise_fnc_terrainSample;
 *
 * Public: No
 */

#define SAMPLE_STEP       100
#define MIN_SPEED         30
#define LOOKAHEAD_MARGIN  1.5
#define MIN_LOOKAHEAD     200

params ["_projectilePosition", "_currentDirection", "_aimDirection", "_yawRate", "_pitchRate", "_cruiseAltitude", "_speed"];

_speed = _speed max MIN_SPEED;

// Horizontal directions
private _horizontalCurrent = [_currentDirection#0, _currentDirection#1, 0];
_horizontalCurrent = if (vectorMagnitude _horizontalCurrent > 0.01) then {vectorNormalized _horizontalCurrent} else {[0, 1, 0]};

private _horizontalAim = [_aimDirection#0, _aimDirection#1, 0];
_horizontalAim = if (vectorMagnitude _horizontalAim > 0.01) then {vectorNormalized _horizontalAim} else {_horizontalCurrent};

// Total angle between current direction and aim direction
private _cosTotalAngle = (_horizontalCurrent vectorDotProduct _horizontalAim) max -1 min 1;
private _totalAngle = acos _cosTotalAngle;

// Turn direction: cross product Z component (positive = counter-clockwise)
private _crossProduct = (_horizontalCurrent#0 * _horizontalAim#1) - (_horizontalCurrent#1 * _horizontalAim#0);
private _turnSign = if (_crossProduct >= 0) then {1} else {-1};

// Physics-based lookahead: distance needed to climb cruiseAltitude using a pull-up arc
// at 80% max pitch rate, plus margin for smoothing/response delay.
// Arc model: to climb H with pitch radius R, angle θ = acos(1 - H/R), horizontal = R * sin(θ)
private _pitchRateEffective = _pitchRate * RATE_USAGE;
private _pitchRadius = if (_pitchRateEffective > 0.1) then {
    _speed / (_pitchRateEffective * (pi / 180))
} else {
    _speed * 100
};
private _climbRatio = (_cruiseAltitude / _pitchRadius) min 1;
private _climbAngle = acos (1 - _climbRatio);
private _climbHorizontalDistance = _pitchRadius * sin _climbAngle;
private _lookahead = (_climbHorizontalDistance * LOOKAHEAD_MARGIN) max MIN_LOOKAHEAD;
private _numSamples = ceil (_lookahead / SAMPLE_STEP);

// Start with terrain directly below (clamped to sea level)
private _desiredAltASL = ((getTerrainHeightASL _projectilePosition) max 0) + _cruiseAltitude;

// Step along the predicted curved path
private _samplePosition = +_projectilePosition;
private _stepDirection = +_horizontalCurrent;
private _angleTurned = 0;
private _stepTime = SAMPLE_STEP / _speed;

for "_i" from 1 to _numSamples do {
    // Rotate direction toward aim by yaw rate for this step's travel time
    private _stepAngle = ((_yawRate * _stepTime) min (_totalAngle - _angleTurned)) max 0;
    if (_stepAngle > 0.01) then {
        private _rotationAngle = _turnSign * _stepAngle;
        private _cosRotation = cos _rotationAngle;
        private _sinRotation = sin _rotationAngle;
        _stepDirection = [
            (_stepDirection#0) * _cosRotation - (_stepDirection#1) * _sinRotation,
            (_stepDirection#0) * _sinRotation + (_stepDirection#1) * _cosRotation,
            0
        ];
        _angleTurned = _angleTurned + _stepAngle;
    };

    // Advance along current direction
    _samplePosition = _samplePosition vectorAdd (_stepDirection vectorMultiply SAMPLE_STEP);
    private _requiredAltitude = ((getTerrainHeightASL _samplePosition) max 0) + _cruiseAltitude;
    _desiredAltASL = _desiredAltASL max _requiredAltitude;
};

_desiredAltASL
