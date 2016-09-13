/*
 * Author: Ruthberg
 * Shows/Hides the range card controls
 *
 * Arguments:
 * visible - <BOOL>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * call ace_atragmx_fnc_show_range_card
 *
 * Public: No
 */
#include "script_component.hpp"

GVAR(showRangeCard) = _this;

{ctrlShow [_x, _this]} forEach [5000, 5001, 5002, 5003, 5004, 5005, 5006, 5007];
