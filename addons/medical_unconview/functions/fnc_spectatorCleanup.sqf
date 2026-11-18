#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Detaches and deletes the spectator camera.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_medical_unconview_fnc_spectatorCleanup
 *
 * Public: No
 */

if (!isNull GVAR(spectatorCam)) then {
    GVAR(spectatorCam) cameraEffect ["terminate", "back", QGVAR(rtt)];
    detach GVAR(spectatorCam);
    camDestroy GVAR(spectatorCam);
};

GVAR(spectatorCam) = objNull;
GVAR(spectatorSelectedAlly) = objNull;
