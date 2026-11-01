#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Points the spectator camera at an ally the same way a cTab helmet camera feed does:
 * camera on the head, looking at a point ahead of the body. Works without a helmet camera item.
 * Creates the camera and target dummy on first use.
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
    GVAR(spectatorTarget) = "Sign_Sphere10cm_F" createVehicleLocal [0, 0, 0];
    hideObject GVAR(spectatorTarget);
    GVAR(spectatorCam) = "camera" camCreate (getPosATL _ally);
    GVAR(spectatorCam) cameraEffect ["internal", "back", QGVAR(rtt)];
} else {
    detach GVAR(spectatorCam);
    detach GVAR(spectatorTarget);
};

GVAR(spectatorSelectedAlly) = _ally;
GVAR(spectatorTarget) attachTo [_ally, [0, 8, 1]];
GVAR(spectatorCam) attachTo [_ally, [0.12, 0, 0.15], "Head"];
GVAR(spectatorCam) camPrepareFov 0.7;
GVAR(spectatorCam) camPrepareTarget GVAR(spectatorTarget);
GVAR(spectatorCam) camCommitPrepared 0;

private _visionMode = [0, currentVisionMode _ally] select (GVAR(spectatorNVGMode) == 1);
QGVAR(rtt) setPiPEffect [_visionMode];
