#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Sets the text of a spectator info box and fits the box width to the text, keeping it centred where it is.
 * The width grows in steps of one box height, so a changing distance does not make the box flicker.
 *
 * Arguments:
 * 0: Info box control <CONTROL>
 * 1: Text <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_infoCtrl, "Spectating Nearest Unit: Bob (12m)"] call ace_medical_unconview_fnc_setSpectatorInfoText
 *
 * Public: No
 */
params ["_ctrl", "_text"];

_ctrl ctrlSetText _text;

(ctrlPosition _ctrl) params ["_x", "_y", "_w", "_h"];
private _centreX = _x + _w / 2;
private _step = _h;
private _width = _step * ceil ((ctrlTextWidth _ctrl + 4 * _step) / _step);
if (_width == _w) exitWith {};

_ctrl ctrlSetPosition [_centreX - _width / 2, _y, _width, _h];
_ctrl ctrlCommit 0;
