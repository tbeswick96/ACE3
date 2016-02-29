/*
 * Author: Dslyecxi
 * Calculate head offset from direction.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Head offset <NUMBER>
 *
 * Example:
 * _headOffset = [] call ace_grenadethrowing_fnc_getHeadOffset
 *
 * Public: No
 */
#include "script_component.hpp"

private _headDir = [player, player modelToWorldVisual [0,10,0]] call CBA_fnc_headDir;

(_headDir select 1) * -1
