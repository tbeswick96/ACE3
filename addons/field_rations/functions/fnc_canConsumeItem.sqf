/*
 * Author: PabstMirror
 * Gets all the children that you can eat
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Player <OBJECT>
 * 2: Item Name <STRING>
 *
 * Return Value:
 * Can Be Disarmed <BOOL>
 *
 * Example:
 * [player, ''] call ace_disarming_fnc_canBeDisarmed
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_3(_target,_player,_itemClassname);

//Have item and (in vehicle or not moving)
(_itemClassname in (items _player)) && {((vehicle _player) != _player) || {(vectorMagnitude (velocity _player)) < 0.1}}
