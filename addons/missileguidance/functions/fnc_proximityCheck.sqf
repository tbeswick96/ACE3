#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Per-tick proximity fuze check for missiles configured with proximityFuze.
 *
 * Algorithm: pure segment math from observed positions, with one-tick forward
 * extrapolation using EMA-smoothed acceleration on both missile and target.
 *
 *   Backward CPA (observed prev → current segment) — fires when the distance
 *     grew this tick AND the sub-tick minimum during the interval is inside the
 *     fuze radius. Teleports projectile to that minimum and detonates.
 *
 *   Forward CPA (current → predicted-next-tick segment) — fires when CPA falls
 *     strictly within the next-tick window AND the predicted minimum is inside
 *     the fuze radius. Direct-hit ray (FIRE then GEOM) checks if engine
 *     collision will fire on the target during the same window — if so, skip
 *     prox and let the engine handle direct + frag damage. Otherwise teleport
 *     to the predicted CPA and detonate.
 *
 *   Backward case beats forward case (observed fact > prediction).
 *
 * Arguments:
 * 0: Guidance Arg Array <ARRAY>
 * 1: Timestep <NUMBER>
 *
 * Return Value:
 * Detonated <BOOL>
 *
 * Public: No
 */
BEGIN_COUNTER(proximityCheck);

params ["_args", "_timestep"];
_args params ["_firedEH", "_launchParams", "", "", "_stateParams"];
_firedEH params ["", "", "", "", "_ammo", "", "_projectile"];
_launchParams params ["", "_targetLaunchParams"];
_targetLaunchParams params ["_target", "", "", "", "_launchTime"];

private _config = configFile >> "CfgAmmo" >> _ammo >> "ace_missileguidance";
if ((getNumber (_config >> "proximityFuze")) < 1) exitWith { END_COUNTER(proximityCheck); false };

private _armingTime = getNumber (_config >> "proximityArmingTime");
private _flightTime = CBA_missionTime - _launchTime;
if (_flightTime < _armingTime) exitWith {
    TRACE_3("prox skip: not armed",_ammo,_flightTime,_armingTime);
    END_COUNTER(proximityCheck);
    false
};

if (isNull _target) exitWith {
    TRACE_2("prox skip: null target",_ammo,_flightTime);
    END_COUNTER(proximityCheck);
    false
};

private _proximityRadius = getNumber (_config >> "proximityRadius");
private _currentProjectilePosition = getPosASLVisual _projectile;
private _currentTargetPosition = getPosASLVisual _target;

// Recover prev-tick state. On first call seed prev = current — no prior motion
// to compute backward CPA from, so the logic naturally degenerates and only
// updates state for next tick.
private _proximityState = _stateParams param [6, []];
_proximityState params [
    ["_previousProjectilePosition", _currentProjectilePosition],
    ["_previousTargetPosition", _currentTargetPosition],
    ["_previousTime", CBA_missionTime],
    ["_previousProjectileDisplacement", [0, 0, 0]],
    ["_previousTargetDisplacement", [0, 0, 0]],
    ["_projectileAccelerationEMA", [0, 0, 0]],
    ["_targetAccelerationEMA", [0, 0, 0]],
    ["_displacementSampleCount", 0],
    ["_targetBodyRadius", -1]
];

// Cache target body extent once. boundingBoxReal returns model-space [min, max]
// vectors; the half-diagonal of the box approximates how far the body extends
// from its position point. Inflating proximity radius by this gives "any part
// of body within fuze distance" semantics rather than strict centre-to-centre.
if (_targetBodyRadius < 0) then {
    private _boundingBox = boundingBoxReal _target;
    _targetBodyRadius = vectorMagnitude (((_boundingBox#1) vectorDiff (_boundingBox#0)) vectorMultiply 0.5);
};
private _effectiveProximityRadius = _proximityRadius + _targetBodyRadius;

private _realDt = (CBA_missionTime - _previousTime) max 0.001;
private _observedProjectileDisplacement = _currentProjectilePosition vectorDiff _previousProjectilePosition;
private _observedTargetDisplacement = _currentTargetPosition vectorDiff _previousTargetPosition;

// Update acceleration EMAs once we have at least two consecutive REAL observed
// displacements. Tick 1: previous-position seed equals current → observed = 0,
// don't sample. Tick 2: first real displacement observed but no real prior to
// diff against → still don't sample. Tick 3+: both this tick's displacement and
// the prev-tick's displacement (in state) are real — compute the per-tick delta.
// Acceleration here is per-tick (not per-second) — applied directly as a
// velocity increment when predicting next tick's displacement.
if (_displacementSampleCount >= 2) then {
    private _projectileAccelerationSample = _observedProjectileDisplacement vectorDiff _previousProjectileDisplacement;
    private _targetAccelerationSample = _observedTargetDisplacement vectorDiff _previousTargetDisplacement;
    _projectileAccelerationEMA = (_projectileAccelerationSample vectorMultiply PROXIMITY_ACCEL_EMA_ALPHA)
        vectorAdd (_projectileAccelerationEMA vectorMultiply (1 - PROXIMITY_ACCEL_EMA_ALPHA));
    _targetAccelerationEMA = (_targetAccelerationSample vectorMultiply PROXIMITY_ACCEL_EMA_ALPHA)
        vectorAdd (_targetAccelerationEMA vectorMultiply (1 - PROXIMITY_ACCEL_EMA_ALPHA));
};

private _predictedNextProjectileDisplacement = _observedProjectileDisplacement vectorAdd _projectileAccelerationEMA;
private _predictedNextTargetDisplacement = _observedTargetDisplacement vectorAdd _targetAccelerationEMA;
private _predictedNextProjectilePosition = _currentProjectilePosition vectorAdd _predictedNextProjectileDisplacement;
private _predictedNextTargetPosition = _currentTargetPosition vectorAdd _predictedNextTargetDisplacement;

// Update state slot now so every early-out path keeps tracking continuous.
_stateParams set [6, [
    _currentProjectilePosition,
    _currentTargetPosition,
    CBA_missionTime,
    _observedProjectileDisplacement,
    _observedTargetDisplacement,
    _projectileAccelerationEMA,
    _targetAccelerationEMA,
    (_displacementSampleCount + 1) min 3,
    _targetBodyRadius
]];

private _separationPrev = _previousProjectilePosition vectorDiff _previousTargetPosition;
private _separationCurrent = _currentProjectilePosition vectorDiff _currentTargetPosition;

private _previousDistance = vectorMagnitude _separationPrev;
private _currentDistance = vectorMagnitude _separationCurrent;

// Coarse distance gate — at long range there is no detonation candidate this
// tick. Skip the CPA math and bail. State has already been updated above so
// continuity is preserved.
if (_currentDistance > _effectiveProximityRadius * PROXIMITY_CHECK_DISTANCE_FACTOR) exitWith {
    TRACE_5("prox skip: out of range",_ammo,_currentDistance,_proximityRadius,_effectiveProximityRadius,_currentDistance / _effectiveProximityRadius);
    END_COUNTER(proximityCheck);
    false
};

private _separationPredictedNext = _predictedNextProjectilePosition vectorDiff _predictedNextTargetPosition;

TRACE_8("prox tick",_ammo,_currentDistance,_previousDistance,_proximityRadius,_targetBodyRadius,_effectiveProximityRadius,_realDt,_flightTime);

// ============================================================================
// BACKWARD CPA — observed segment from previous to current sample.
// ============================================================================
private _separationDeltaBackward = _separationCurrent vectorDiff _separationPrev;
private _separationDeltaBackwardSq = _separationDeltaBackward vectorDotProduct _separationDeltaBackward;
private _backwardCPATimeNormalised = if (_separationDeltaBackwardSq > 1e-9) then {
    (- (_separationPrev vectorDotProduct _separationDeltaBackward)) / _separationDeltaBackwardSq
} else {
    0
};
private _backwardCPATimeClamped = (_backwardCPATimeNormalised max 0) min 1;
private _backwardCPASeparation = _separationPrev vectorAdd (_separationDeltaBackward vectorMultiply _backwardCPATimeClamped);
private _backwardCPADistance = vectorMagnitude _backwardCPASeparation;

private _projectileMotionThisTick = _currentProjectilePosition vectorDiff _previousProjectilePosition;
private _targetMotionThisTick = _currentTargetPosition vectorDiff _previousTargetPosition;
// Past spacetime positions at the CPA moment — used for viz only.
private _projectilePositionAtBackwardCPA = _previousProjectilePosition vectorAdd (_projectileMotionThisTick vectorMultiply _backwardCPATimeClamped);
private _targetPositionAtBackwardCPA = _previousTargetPosition vectorAdd (_targetMotionThisTick vectorMultiply _backwardCPATimeClamped);
// Detonation teleport position — anchors the CPA relative-vector to the
// target's CURRENT position so that triggerAmmo (which fires instantly with
// target wherever it actually is now) puts the missile at exactly cpaDistance
// from current target, with the same relative direction as at CPA.
private _backwardDetonationPosition = _currentTargetPosition vectorAdd _backwardCPASeparation;

private _distanceGrewThisTick = _currentDistance > _previousDistance;

TRACE_5("prox backward CPA",_backwardCPATimeNormalised,_backwardCPATimeClamped,_backwardCPADistance,_distanceGrewThisTick,_separationDeltaBackwardSq);

// ============================================================================
// FORWARD CPA — predicted segment from current sample to extrapolated next.
// ============================================================================
private _separationDeltaForward = _separationPredictedNext vectorDiff _separationCurrent;
private _separationDeltaForwardSq = _separationDeltaForward vectorDotProduct _separationDeltaForward;
private _forwardCPATimeNormalised = if (_separationDeltaForwardSq > 1e-9) then {
    (- (_separationCurrent vectorDotProduct _separationDeltaForward)) / _separationDeltaForwardSq
} else {
    -1  // sentinel — no forward CPA detectable, defer
};
private _forwardCPAInWindow = _forwardCPATimeNormalised > 0 && _forwardCPATimeNormalised <= 1;

private _forwardCPATimeClamped = (_forwardCPATimeNormalised max 0) min 1;
private _forwardCPASeparation = _separationCurrent vectorAdd (_separationDeltaForward vectorMultiply _forwardCPATimeClamped);
private _forwardCPADistance = vectorMagnitude _forwardCPASeparation;

private _projectileMotionNextTick = _predictedNextProjectilePosition vectorDiff _currentProjectilePosition;
private _targetMotionNextTick = _predictedNextTargetPosition vectorDiff _currentTargetPosition;
// Future spacetime positions at predicted CPA — used for viz only.
private _projectilePositionAtForwardCPA = _currentProjectilePosition vectorAdd (_projectileMotionNextTick vectorMultiply _forwardCPATimeClamped);
private _targetPositionAtForwardCPA = _currentTargetPosition vectorAdd (_targetMotionNextTick vectorMultiply _forwardCPATimeClamped);
// Detonation teleport — same anchor-to-current-target principle as backward.
private _forwardDetonationPosition = _currentTargetPosition vectorAdd _forwardCPASeparation;

TRACE_5("prox forward CPA",_forwardCPATimeNormalised,_forwardCPATimeClamped,_forwardCPADistance,_forwardCPAInWindow,_separationDeltaForwardSq);

// ============================================================================
// LIVE PER-TICK DEBUG DRAWS — only when within close-approach distance.
// ============================================================================
#ifdef DRAW_GUIDANCE_INFO
if (GVAR(debug_drawGuidanceInfo)) then {
    private _currentProjectilePositionAGL = ASLToAGL _currentProjectilePosition;
    private _currentTargetPositionAGL = ASLToAGL _currentTargetPosition;

    // Current separation
    drawLine3D [_currentProjectilePositionAGL, _currentTargetPositionAGL, [0, 1, 1, 0.4]];

    // Predicted next-tick path (yellow dashed feel via low alpha)
    drawLine3D [_currentProjectilePositionAGL, ASLToAGL _predictedNextProjectilePosition, [1, 1, 0, 0.4]];
    drawLine3D [_currentTargetPositionAGL, ASLToAGL _predictedNextTargetPosition, [1, 1, 0, 0.4]];

    // Backward CPA marker (orange) and forward CPA marker (red)
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0.5, 0, 0.6], ASLToAGL _projectilePositionAtBackwardCPA, 0.3, 0.3, 0, "", 1, 0.025, "TahomaB"];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [1, 0, 0, 0.6], ASLToAGL _projectilePositionAtForwardCPA, 0.3, 0.3, 0, "", 1, 0.025, "TahomaB"];

    // Live state label at projectile
    drawIcon3D ["", [0, 1, 1, 1], _currentProjectilePositionAGL, 0, 0, 0,
        format ["radius=%1 (raw=%2 + body=%3)  currDist=%4  prevDist=%5  realDt=%6ms", _effectiveProximityRadius toFixed 2, _proximityRadius, _targetBodyRadius toFixed 2, _currentDistance toFixed 2, _previousDistance toFixed 2, (_realDt * 1000) toFixed 1],
        1, 0.025, "TahomaB", "center", false, 0, -0.04];
    drawIcon3D ["", [1, 0.5, 0, 1], _currentProjectilePositionAGL, 0, 0, 0,
        format ["BACK  uClamp=%1 uRaw=%2  dist=%3  grew=%4", _backwardCPATimeClamped toFixed 2, _backwardCPATimeNormalised toFixed 2, _backwardCPADistance toFixed 2, _distanceGrewThisTick],
        1, 0.025, "TahomaB", "center", false, 0, -0.06];
    drawIcon3D ["", [1, 0, 0, 1], _currentProjectilePositionAGL, 0, 0, 0,
        format ["FWD   uClamp=%1 uRaw=%2  dist=%3  inWindow=%4", _forwardCPATimeClamped toFixed 2, _forwardCPATimeNormalised toFixed 2, _forwardCPADistance toFixed 2, _forwardCPAInWindow],
        1, 0.025, "TahomaB", "center", false, 0, -0.08];
};
#endif

// ============================================================================
// DECISIONS
// ============================================================================

if (_distanceGrewThisTick && {_backwardCPADistance <= _effectiveProximityRadius}) exitWith {
    ["BACKWARD",
        _projectilePositionAtBackwardCPA, _targetPositionAtBackwardCPA,
        _backwardCPATimeClamped, _backwardCPADistance,
        _previousProjectilePosition, _currentProjectilePosition,
        _previousTargetPosition, _currentTargetPosition,
        _predictedNextProjectilePosition, _predictedNextTargetPosition,
        _effectiveProximityRadius, _realDt,
        _projectileAccelerationEMA, _targetAccelerationEMA
    ] call FUNC(proximityCheck_pushDetonationViz);

    _projectile setPosASL _backwardDetonationPosition;
    TRACE_7("prox detonation: BACKWARD",_ammo,_target,_backwardCPADistance,_proximityRadius,_effectiveProximityRadius,_backwardCPATimeClamped,_realDt);
    triggerAmmo _projectile;
    END_COUNTER(proximityCheck);
    true
};

if (!_forwardCPAInWindow || {_forwardCPADistance > _effectiveProximityRadius}) exitWith {
    TRACE_5("prox defer",_forwardCPAInWindow,_forwardCPADistance,_proximityRadius,_effectiveProximityRadius,_currentDistance);
    END_COUNTER(proximityCheck);
    false
};

// ============================================================================
// DIRECT-HIT TWO-SEGMENT RAY — only run when forward CPA is going to fire.
// segA uses last observed displacement direction; segB bends with accel-corrected
// next-tick displacement. FIRE LOD first, GEOM fallback per segment. If either
// hits target (or any of target's children), engine collision will fire on this
// same window — skip prox to avoid double detonation.
// ============================================================================
private _matchesTarget = { (_x param [2, objNull] == _target) || {_x param [3, objNull] == _target} };

private _raySegmentAStart = _currentProjectilePosition;
private _raySegmentAEnd = _currentProjectilePosition vectorAdd _observedProjectileDisplacement;
private _raySegmentBStart = _raySegmentAEnd;
private _raySegmentBEnd = _raySegmentAEnd vectorAdd _predictedNextProjectileDisplacement;

private _segmentAFireHits = lineIntersectsSurfaces [_raySegmentAStart, _raySegmentAEnd, _projectile, objNull, true, 4, "FIRE", "NONE"];
private _segmentAHits = _segmentAFireHits;
private _segmentAGeomHits = [];
if ((_segmentAHits findIf _matchesTarget) == -1) then {
    _segmentAGeomHits = lineIntersectsSurfaces [_raySegmentAStart, _raySegmentAEnd, _projectile, objNull, true, 4, "GEOM", "NONE"];
    _segmentAHits = _segmentAGeomHits;
};
private _segmentAHitsTarget = (_segmentAHits findIf _matchesTarget) != -1;

private _segmentBFireHits = [];
private _segmentBGeomHits = [];
private _segmentBHitsTarget = false;
if (!_segmentAHitsTarget) then {
    _segmentBFireHits = lineIntersectsSurfaces [_raySegmentBStart, _raySegmentBEnd, _projectile, objNull, true, 4, "FIRE", "NONE"];
    private _segmentBHits = _segmentBFireHits;
    if ((_segmentBHits findIf _matchesTarget) == -1) then {
        _segmentBGeomHits = lineIntersectsSurfaces [_raySegmentBStart, _raySegmentBEnd, _projectile, objNull, true, 4, "GEOM", "NONE"];
        _segmentBHits = _segmentBGeomHits;
    };
    _segmentBHitsTarget = (_segmentBHits findIf _matchesTarget) != -1;
};

TRACE_8("prox direct-hit probe",_target,count _segmentAFireHits,count _segmentAGeomHits,_segmentAHitsTarget,count _segmentBFireHits,count _segmentBGeomHits,_segmentBHitsTarget,vectorMagnitude (_raySegmentBEnd vectorDiff _raySegmentAStart));

if (_segmentAHitsTarget || _segmentBHitsTarget) exitWith {
    [_raySegmentAStart, _raySegmentAEnd, _raySegmentBEnd,
        _segmentAHitsTarget, _segmentBHitsTarget,
        _forwardCPADistance, _effectiveProximityRadius
    ] call FUNC(proximityCheck_pushDirectHitViz);

    TRACE_5("prox skip: direct hit predicted",_forwardCPADistance,_segmentAHitsTarget,_segmentBHitsTarget,_proximityRadius,_effectiveProximityRadius);
    END_COUNTER(proximityCheck);
    false
};

// ============================================================================
// FORWARD CPA DETONATION
// ============================================================================
["FORWARD",
    _projectilePositionAtForwardCPA, _targetPositionAtForwardCPA,
    _forwardCPATimeClamped, _forwardCPADistance,
    _previousProjectilePosition, _currentProjectilePosition,
    _previousTargetPosition, _currentTargetPosition,
    _predictedNextProjectilePosition, _predictedNextTargetPosition,
    _proximityRadius, _realDt,
    _projectileAccelerationEMA, _targetAccelerationEMA
] call FUNC(proximityCheck_pushDetonationViz);

_projectile setPosASL _forwardDetonationPosition;
TRACE_7("prox detonation: FORWARD",_ammo,_target,_forwardCPADistance,_proximityRadius,_effectiveProximityRadius,_forwardCPATimeClamped,_realDt);
triggerAmmo _projectile;
END_COUNTER(proximityCheck);
true
