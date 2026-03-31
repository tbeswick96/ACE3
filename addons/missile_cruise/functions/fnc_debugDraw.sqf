#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Debug visualization for cruise missile guidance.
 * Draws target, waypoints, aim point, altitude readouts, and terrain profile.
 * Called from fnc_attackProfile when debug drawing is enabled.
 *
 * Arguments:
 * 0: Projectile <OBJECT>
 * 1: Projectile Position ASL <ARRAY>
 * 2: Velocity Direction (normalized) <ARRAY>
 * 3: Speed <NUMBER>
 * 4: Current AGL <NUMBER>
 * 5: Horizontal Distance to Target <NUMBER>
 * 6: Attack Profile State Params <ARRAY>
 * 7: Target Position ASL <ARRAY>
 * 8: Has Attack Direction <BOOL>
 * 9: Attack Direction Vector <ARRAY>
 * 10: Return Target Position (aim point) <ARRAY>
 * 11: Terrain Follow Aim Direction <ARRAY>
 * 12: Yaw Rate <NUMBER>
 * 13: Pitch Rate <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [...] call ace_missile_cruise_fnc_debugDraw;
 *
 * Public: No
 */

params [
    "_projectile", "_projectilePosition", "_velocityDirection", "_speed",
    "_currentAGL", "_horizontalDistance",
    "_attackProfileStateParams", "_targetPositionASL",
    "_hasAttackDirection", "_attackDirectionVector",
    "_returnTargetPosition", "_terrainFollowAimDirection",
    "_yawRate", "_pitchRate"
];

_attackProfileStateParams params [
    "_stage", "_gpsData", "_cruiseAltitude", "",
    "", "_lastDesiredAltitude", "_waypoints", "_currentWaypointIndex"
];
_gpsData params ["", "_impactAngle"];

private _pitchRateEffective = _pitchRate * RATE_USAGE;

// Target position - red icon
drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,0,0,1], ASLToAGL _targetPositionASL, 0.75, 0.75, 0, "TARGET", 1, 0.025, "TahomaB"];

// Attack direction line - white
if (_hasAttackDirection) then {
    private _targetAGL = ASLToAGL _targetPositionASL;
    drawLine3D [_targetAGL, _targetAGL vectorAdd (_attackDirectionVector vectorMultiply 2000), [1,1,1,1]];
};

// Waypoints - yellow icons with connecting lines (includes approach WP as last)
if (count _waypoints > 0) then {
    private _previousPosition = [];
    private _lastWaypointIndex = count _waypoints - 1;
    {
        if (count _x < 3) then {continue};
        private _waypointAGL = ASLToAGL _x;
        private _isCurrent = _forEachIndex == _currentWaypointIndex;
        private _isApproach = _forEachIndex == _lastWaypointIndex && {_hasAttackDirection};
        private _color = if (_isCurrent) then {[1,1,0,1]} else {[1,0.7,0,0.6]};
        private _label = if (_isApproach) then {
            ["APP", "APP >"] select _isCurrent
        } else {
            format [["WP %1", "WP %1 >"] select _isCurrent, _forEachIndex + 1]
        };
        if (_isApproach) then {_color = [0,1,0,1]};
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", _color, _waypointAGL, 0.5, 0.5, 0, _label, 1, 0.02, "TahomaB"];
        if (_previousPosition isNotEqualTo []) then {
            drawLine3D [ASLToAGL _previousPosition, _waypointAGL, [1,0.7,0,0.4]];
        };
        _previousPosition = _x;
    } forEach _waypoints;
};

// Return aim position - cyan icon
if (count _returnTargetPosition >= 3) then {
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,1,1], ASLToAGL _returnTargetPosition, 0.5, 0.5, 0, "AIM", 1, 0.025, "TahomaB"];
} else {
    ERROR_2("drawAIM: _returnTargetPosition invalid count=%1 val=%2",count _returnTargetPosition,_returnTargetPosition);
};

// --- Missile height readouts (using offsetY to avoid overlap with guidance PFH labels) ---
private _missileAGL = ASLToAGL _projectilePosition;
private _terrainASLHere = getTerrainHeightASL _projectilePosition;
private _clearance = _projectilePosition#2 - (_terrainASLHere max 0);
private _clearanceColor = if (_clearance < _cruiseAltitude * 0.5) then {[1,0,0,1]} else {[0,1,0,1]};

drawIcon3D ["", [1,1,1,1], _missileAGL, 0, 0, 0,
    format ["ASL: %1m", round (_projectilePosition#2)], 1, 0.022, "TahomaB", "center", false, 0, 0.01];
drawIcon3D ["", [1,1,0,1], _missileAGL, 0, 0, 0,
    format ["ATL: %1m (ter:%2)", round (_projectilePosition#2 - _terrainASLHere), round _terrainASLHere], 1, 0.022, "TahomaB", "center", false, 0, 0.02];
drawIcon3D ["", [0,1,0,1], _missileAGL, 0, 0, 0,
    format ["AGL: %1m", round (_missileAGL#2)], 1, 0.022, "TahomaB", "center", false, 0, 0.03];
drawIcon3D ["", _clearanceColor, _missileAGL, 0, 0, 0,
    format ["CLR: %1m", round _clearance], 1, 0.022, "TahomaB", "center", false, 0, 0.04];

// Desired altitude (magenta)
if (_stage in [STAGE_CRUISE, STAGE_WAYPOINT, STAGE_APPROACH] && {_lastDesiredAltitude > 0}) then {
    private _desiredATL = _lastDesiredAltitude - _terrainASLHere;
    private _desiredAGL = (ASLToAGL [_projectilePosition#0, _projectilePosition#1, _lastDesiredAltitude])#2;
    drawIcon3D ["", [1, 0, 1, 1], _missileAGL, 0, 0, 0,
        format ["DES ASL:%1 ATL:%2 AGL:%3", round _lastDesiredAltitude, round _desiredATL, round _desiredAGL], 1, 0.022, "TahomaB", "center", false, 0, 0.05];
};

// Terminal dive line
if (_stage == STAGE_TERMINAL) then {
    private _finalAttackDirection = _gpsData#2;
    private _lineDirection = [1, 180 + _finalAttackDirection, _impactAngle] call CBA_fnc_polar2vect;
    private _targetAGL = ASLToAGL _targetPositionASL;
    drawLine3D [_targetAGL, _targetAGL vectorAdd (_lineDirection vectorMultiply 3000), [1,0.5,0,1]];
};

// --- Terrain following profile with peak readouts (curved path) ---
if (_stage in [STAGE_CRUISE, STAGE_WAYPOINT, STAGE_APPROACH]) then {
    private _profileSpeed = _speed max 30;

    // Replicate the curved path from terrainSample for debug visualization
    private _profileCurrentDirection = [_velocityDirection#0, _velocityDirection#1, 0];
    _profileCurrentDirection = if (vectorMagnitude _profileCurrentDirection > 0.01) then {vectorNormalized _profileCurrentDirection} else {[0,1,0]};
    private _profileAimDirection = [_terrainFollowAimDirection#0, _terrainFollowAimDirection#1, 0];
    _profileAimDirection = if (vectorMagnitude _profileAimDirection > 0.01) then {vectorNormalized _profileAimDirection} else {_profileCurrentDirection};

    private _profileCosTotalAngle = (_profileCurrentDirection vectorDotProduct _profileAimDirection) max -1 min 1;
    private _profileTotalAngle = acos _profileCosTotalAngle;
    private _profileCrossProduct = (_profileCurrentDirection#0 * _profileAimDirection#1) - (_profileCurrentDirection#1 * _profileAimDirection#0);
    private _profileTurnSign = if (_profileCrossProduct >= 0) then {1} else {-1};

    // Physics-based lookahead matching terrainSample: climb arc distance + margin
    private _profilePitchRadius = if (_pitchRateEffective > 0.1) then {
        _profileSpeed / (_pitchRateEffective * (pi / 180))
    } else {
        _profileSpeed * 100
    };
    private _profileClimbRatio = (_cruiseAltitude / _profilePitchRadius) min 1;
    private _profileClimbAngle = acos (1 - _profileClimbRatio);
    private _maxLookahead = ((_profilePitchRadius * sin _profileClimbAngle) * 1.5) max 200;
    private _numSamples = ceil (_maxLookahead / 100);
    private _profileStepTime = 100 / _profileSpeed;

    private _previousPoint = [];
    private _peakAltitude = 0;
    private _peakPosition = [];
    private _peakDistance = 0;

    private _profilePosition = +_projectilePosition;
    private _profileDirection = +_profileCurrentDirection;
    private _profileAngleTurned = 0;

    for "_i" from 0 to _numSamples do {
        if (_i > 0) then {
            // Rotate toward aim direction
            private _stepAngle = ((_yawRate * _profileStepTime) min (_profileTotalAngle - _profileAngleTurned)) max 0;
            if (_stepAngle > 0.01) then {
                private _rotationAngle = _profileTurnSign * _stepAngle;
                private _cosRotation = cos _rotationAngle;
                private _sinRotation = sin _rotationAngle;
                _profileDirection = [
                    (_profileDirection#0) * _cosRotation - (_profileDirection#1) * _sinRotation,
                    (_profileDirection#0) * _sinRotation + (_profileDirection#1) * _cosRotation,
                    0
                ];
                _profileAngleTurned = _profileAngleTurned + _stepAngle;
            };
            _profilePosition = _profilePosition vectorAdd (_profileDirection vectorMultiply 100);
        };

        private _sampleDistance = _i * 100;
        private _terrainHeight = (getTerrainHeightASL _profilePosition) max 0;
        private _requiredAltitude = _terrainHeight + _cruiseAltitude;
        private _pointAGL = ASLToAGL [_profilePosition#0, _profilePosition#1, _requiredAltitude];

        // Track peak (highest required altitude in lookahead)
        if (_requiredAltitude > _peakAltitude) then {
            _peakAltitude = _requiredAltitude;
            _peakPosition = +_profilePosition;
            _peakDistance = _sampleDistance;
        };

        // Connected terrain profile line
        if (_previousPoint isNotEqualTo []) then {
            drawLine3D [_previousPoint, _pointAGL, [1, 1, 0, 0.5]];
        };
        _previousPoint = _pointAGL;

        // Label every 4th point for clarity
        if (_i > 0 && {_i % 4 == 0}) then {
            drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,0,0.7], _pointAGL, 0.3, 0.3, 0, format ["%1m", round _sampleDistance], 1, 0.02, "TahomaB"];
        };
    };

    // --- TF peak (lookahead) readouts — each at its actual height ---
    if (_peakPosition isNotEqualTo []) then {
        private _peakTerrainASL = getTerrainHeightASL _peakPosition;
        private _peakATL = _peakAltitude - _peakTerrainASL;
        private _peakAGL = (ASLToAGL [_peakPosition#0, _peakPosition#1, _peakAltitude])#2;

        // TF PEAK header (cyan) — at cruise target ASL height
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,1,1],
            ASLToAGL [_peakPosition#0, _peakPosition#1, _peakAltitude], 0.4, 0.4, 0,
            format ["TF PEAK @%1m", round _peakDistance], 1, 0.022, "TahomaB"];

        // TGT ASL (white) — at cruise target ASL height, offset X
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,1,0.9],
            ASLToAGL [_peakPosition#0 + 3, _peakPosition#1, _peakAltitude], 0.25, 0.25, 0,
            format ["TGT ASL: %1m (ter:%2)", round _peakAltitude, round _peakTerrainASL], 1, 0.022, "TahomaB"];

        // TGT ATL (yellow) — at ATL height above terrain
        private _atlPeakASL = _peakTerrainASL + _peakATL;
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1,1,0,0.9],
            ASLToAGL [_peakPosition#0 - 3, _peakPosition#1, _atlPeakASL], 0.25, 0.25, 0,
            format ["TGT ATL: %1m", round _peakATL], 1, 0.022, "TahomaB"];

        // TGT AGL (green) — at AGL height above ground
        drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0,1,0,0.9],
            [_peakPosition#0, _peakPosition#1, _peakAGL], 0.25, 0.25, 0,
            format ["TGT AGL: %1m", round _peakAGL], 1, 0.022, "TahomaB"];
    };
};
