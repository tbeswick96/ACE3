#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Spectator PFH body. Finds nearest non-uncon ally on player's side and shows their helmet-cam style feed.
 * In multiplayer only human players are candidates; in singleplayer AI allies are candidates too.
 * Manages info text visibility: NoSignal (no allies), TooFar (beyond range), or SpecInfo (active).
 *
 * Arguments:
 * Standard PFH args: [_args, _idPFH]
 *
 * Return Value:
 * None
 *
 * Example:
 * Registered via openSpectatorTab
 *
 * Public: No
 */
params ["_args", "_idPFH"];

private _display = findDisplay IDD_UNCON;
if (isNull _display) exitWith {
    [_idPFH] call CBA_fnc_removePerFrameHandler;
    GVAR(activeSpectatorPFH) = -1;
};

private _tooFarCtrl = _display displayCtrl IDC_SPEC_TOO_FAR;
private _infoCtrl = _display displayCtrl IDC_SPEC_INFO;
private _noSignalCtrl = _display displayCtrl IDC_SPEC_NO_SIGNAL;
private _pipCtrl = _display displayCtrl IDC_SPEC_PIP;
private _maxDistance = GVAR(spectatorDistance);
private _spectatorTabOpen = GVAR(currentTab) == "spectator";

private _pool = if (isMultiplayer) then { allPlayers - entities "HeadlessClient_F" } else { allUnits };
private _candidates = _pool select {
    side _x == side group ACE_player &&
    {alive _x} &&
    {_x != ACE_player} &&
    {!(_x getVariable ["ACE_isUnconscious", false])}
};

if (_candidates isEqualTo []) exitWith {
    [] call FUNC(spectatorCleanup);
    if (_spectatorTabOpen) then {
        _tooFarCtrl ctrlShow false;
        _infoCtrl ctrlShow false;
        _pipCtrl ctrlShow false;
        _noSignalCtrl ctrlEnable true;
        _noSignalCtrl ctrlShow true;
    };
};

_candidates = _candidates apply { [_x distance ACE_player, _x] };
_candidates sort true;

(_candidates # 0) params ["_distance", "_nearestAlly"];

if (_distance > _maxDistance) exitWith {
    [] call FUNC(spectatorCleanup);
    if (_spectatorTabOpen) then {
        _tooFarCtrl ctrlSetText format ["Too Far Away To Spectate! Nearest Unit: %1 (%2m)", name _nearestAlly, round _distance];
        _tooFarCtrl ctrlEnable true;
        _tooFarCtrl ctrlShow true;
        _infoCtrl ctrlShow false;
        _noSignalCtrl ctrlShow false;
        _pipCtrl ctrlShow false;
    };
};

if (_nearestAlly != GVAR(spectatorSelectedAlly) || {isNull GVAR(spectatorCam)}) then {
    [_nearestAlly] call FUNC(spectatorAttachCamera);
};

if (_spectatorTabOpen) then {
    _infoCtrl ctrlSetText format ["Spectating Nearest Unit: %1 (%2m)", name _nearestAlly, round _distance];
    _infoCtrl ctrlEnable true;
    _infoCtrl ctrlShow true;
    _pipCtrl ctrlEnable true;
    _pipCtrl ctrlShow true;
    _tooFarCtrl ctrlShow false;
    _noSignalCtrl ctrlShow false;
};
