#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Detaches and deletes spectator camera + target dummy.
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

if (!isNull GVAR(spectatorTarget)) then {
    deleteVehicle GVAR(spectatorTarget);
};

GVAR(spectatorCam) = objNull;
GVAR(spectatorTarget) = objNull;
GVAR(spectatorSelectedAlly) = objNull;
