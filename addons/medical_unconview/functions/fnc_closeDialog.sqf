#include "..\script_component.hpp"
/*
 * Author: Tim Beswick
 * Closes the uncon dialog via closeDisplay; onDialogUnload performs the teardown.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_medical_unconview_fnc_closeDialog
 *
 * Public: No
 */

if (!isNull findDisplay IDD_UNCON) then {
    (findDisplay IDD_UNCON) closeDisplay 2;
};
