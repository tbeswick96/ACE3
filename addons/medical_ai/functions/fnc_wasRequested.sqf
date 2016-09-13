/*
 * Author: BaerMitUmlaut
 * Checks if the unit was requested to treat another unit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Was requested <BOOL>
 *
 * Public: No
 */
#include "script_component.hpp"

private _healQueue = _this getVariable [QGVAR(healQueue), []];
!(_healQueue isEqualTo [])
