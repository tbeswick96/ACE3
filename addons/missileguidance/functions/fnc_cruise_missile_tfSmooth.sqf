#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Terrain-following altitude smoother for cruise missile guidance.
 *
 * Applies minimal smoothing to the terrain sampler output.
 * Climbs are unsmoothed (instant response) to ensure terrain clearance.
 * Descents use light smoothing (0.9) to prevent jitter on uneven terrain
 * while still tracking contours closely.
 *
 * Arguments:
 * 0: Projectile Position ASL <ARRAY>
 * 1: Current Velocity Direction (normalized) <ARRAY>
 * 2: Aim Direction (normalized) <ARRAY>
 * 3: Yaw Rate (degrees/second) <NUMBER>
 * 4: Pitch Rate (degrees/second) <NUMBER>
 * 5: Cruise Altitude AGL <NUMBER>
 * 6: Current Speed (m/s) <NUMBER>
 * 7: Last Desired Altitude ASL <NUMBER>
 *
 * Return Value:
 * Smoothed Altitude ASL <NUMBER>
 *
 * Example:
 * [getPosASLVisual _proj, _velDirection, _aimDirection, _yawRate, _pitchRate, 50, speed _proj, _lastAltitude] call ace_missileguidance_fnc_cruise_missile_tfSmooth;
 *
 * Public: No
 */

params ["_projectilePosition", "_currentDirection", "_aimDirection", "_yawRate", "_pitchRate", "_cruiseAltitude", "_speed", "_lastDesiredAltitude"];

private _desiredAltASL = [_projectilePosition, _currentDirection, _aimDirection, _yawRate, _pitchRate, _cruiseAltitude, _speed] call FUNC(cruise_missile_terrainSample);

// Climbs: instant. Descents: light smoothing to prevent jitter.
if (_lastDesiredAltitude > 0 && {_desiredAltASL < _lastDesiredAltitude}) then {
    (_lastDesiredAltitude * 0.1) + (_desiredAltASL * 0.9)
} else {
    _desiredAltASL
}
