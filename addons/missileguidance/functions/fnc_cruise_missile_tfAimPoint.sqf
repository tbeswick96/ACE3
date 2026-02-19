#include "..\script_component.hpp"
#include "..\cruise_missile_defines.hpp"
/*
 * Author: UKSF
 * Compute terrain-following aim point for cruise missile guidance.
 *
 * Combines horizontal navigation (toward a waypoint) with vertical terrain
 * following. The aim point is placed in the direction of the navigation
 * target at a distance derived from pitch arc physics + response lag.
 *
 * Lead = reaction distance + pitch arc distance for the altitude error.
 * Reaction distance (speed * response time) covers the lag before
 * control surfaces take effect. The arc distance covers the actual
 * pitch maneuver at 80% max rate.
 *
 * Arguments:
 * 0: Navigation Target PosASL <ARRAY>
 * 1: Desired Altitude ASL <NUMBER>
 * 2: Projectile Position ASL <ARRAY>
 * 3: Velocity Direction (normalized) <ARRAY>
 * 4: Pitch Rate (degrees/second) <NUMBER>
 * 5: Current Speed (m/s) <NUMBER>
 *
 * Return Value:
 * Aim Position ASL <ARRAY>
 *
 * Example:
 * [_aimOnLeg, _desiredAlt, getPosASLVisual _proj, vectorNormalized velocity _proj, _pitchRate, speed _proj] call ace_missileguidance_fnc_cruise_missile_tfAimPoint;
 *
 * Public: No
 */

params ["_navTarget", "_desiredAltitude", "_projectilePosition", "_velocityDirection", "_pitchRate", "_speed"];

if (!(_navTarget isEqualType []) || {count _navTarget < 3}) exitWith {
    ERROR_4("tfAimPoint: navTarget invalid type=%1 count=%2 val=%3 projectilePosition=%4",typeName _navTarget,count _navTarget,_navTarget,_projectilePosition);
    _projectilePosition
};

private _navigationDirection = [_navTarget#0 - _projectilePosition#0, _navTarget#1 - _projectilePosition#1, 0];
private _navigationDistance = vectorMagnitude _navigationDirection;
private _navigationDirectionNormalized = if (_navigationDistance > 0.1) then {_navigationDirection vectorMultiply (1 / _navigationDistance)} else {_velocityDirection};

// Pitch radius at 80% max rate: R = speed / angular_velocity
private _pitchRateEffective = _pitchRate * RATE_USAGE;
private _pitchRadius = if (_pitchRateEffective > 0.1) then {
    _speed / (_pitchRateEffective * (pi / 180))
} else {
    _speed * 100
};

// Lead = reaction distance + pitch arc for altitude error
// Reaction: missile continues straight during control surface response lag
// Arc: horizontal distance of pitch maneuver at 80% rate
private _reactionDistance = _speed * RESPONSE_TIME;
private _altitudeError = abs (_desiredAltitude - _projectilePosition#2);
private _climbRatio = (_altitudeError / _pitchRadius) min 1;
private _arcAngle = acos (1 - _climbRatio);
private _adaptiveLeadDistance = _reactionDistance + _pitchRadius * sin _arcAngle;
private _leadDistance = _navigationDistance min _adaptiveLeadDistance;

private _aimPosition = _projectilePosition vectorAdd (_navigationDirectionNormalized vectorMultiply _leadDistance);
_aimPosition set [2, _desiredAltitude];

_aimPosition
