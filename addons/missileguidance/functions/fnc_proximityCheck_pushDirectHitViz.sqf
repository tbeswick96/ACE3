#include "..\script_component.hpp"
/*
 * Author: tim/uksf
 * Push a 3-second persistent debug viz for a prox-fuze direct-hit-skip event.
 * Drawn each frame by the PFEH registered in XEH_postInit.sqf.
 *
 * Visualises the two-segment forward direct-hit ray in green and a label
 * indicating the engine will handle this hit.
 *
 * Arguments:
 * 0: Ray segment A start (ASL) <ARRAY>
 * 1: Ray segment A end / segment B start (ASL) <ARRAY>
 * 2: Ray segment B end (ASL) <ARRAY>
 * 3: Segment A hit target <BOOL>
 * 4: Segment B hit target <BOOL>
 * 5: Forward CPA distance (would-have-been) <NUMBER>
 * 6: Proximity radius <NUMBER>
 *
 * Public: No
 */
if (!hasInterface || {!GVAR(debug_drawGuidanceInfo)}) exitWith {};

params [
    "_raySegmentAStart", "_raySegmentAEnd", "_raySegmentBEnd",
    "_segmentAHitsTarget", "_segmentBHitsTarget",
    "_forwardCPADistance", "_proximityRadius"
];

private _expireTime = CBA_missionTime + PROXIMITY_DEBUG_DRAW_TTL_DIRECT_HIT;
private _hitSegmentLabel = ["B", "A"] select _segmentAHitsTarget;
private _label = format [
    "DIRECT HIT PREDICTED (segment %1) — engine handles  | wouldBeProx dist=%2 / radius=%3",
    _hitSegmentLabel,
    _forwardCPADistance toFixed 2,
    _proximityRadius toFixed 1
];

GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [0, 1, 0, 1]];
}, [_raySegmentAStart, _raySegmentAEnd]];

GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_a", "_b"];
    drawLine3D [ASLToAGL _a, ASLToAGL _b, [0, 1, 0, 1]];
}, [_raySegmentAEnd, _raySegmentBEnd]];

GVAR(proxDebug_pendingDraws) pushBack [_expireTime, {
    params ["_position", "_label"];
    drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Cursors\selectover_ca.paa", [0, 1, 0, 1], ASLToAGL _position, 0.5, 0.5, 0, _label, 1, 0.03, "TahomaB", "center", false, 0, -0.06];
}, [_raySegmentAEnd, _label]];
