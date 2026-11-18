#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Points the spectator camera at an ally the same way a Modern ATAK live cam does:
 * camera on the chest, looking forward with the body. Works without a camera item.
 * Creates the camera on first use.
 *
 * Arguments:
 * 0: Ally to spectate <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [cursorObject] call ace_medical_unconview_fnc_spectatorAttachCamera
 *
 * Public: No
 */
params ["_ally"];

if (isNull GVAR(spectatorCam)) then {
    GVAR(spectatorCam) = "camera" camCreate (getPosATL _ally);
    GVAR(spectatorCam) cameraEffect ["internal", "back", QGVAR(rtt)];
} else {
    detach GVAR(spectatorCam);
};

GVAR(spectatorSelectedAlly) = _ally;
GVAR(spectatorCam) camSetFov 0.75;
GVAR(spectatorCam) camCommit 0;
GVAR(spectatorCam) attachTo [_ally, [0, 0.22, 0.05], "spine3", true];
GVAR(spectatorCam) setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];

private _visionMode = [0, currentVisionMode _ally] select (GVAR(spectatorNVGMode) == 1);
QGVAR(rtt) setPiPEffect [_visionMode];
