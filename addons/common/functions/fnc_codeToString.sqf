/*
 * Author: commy2
 * Removes the brackets around a code and returns the code as a string. It does nothing if the code is already a string.
 *
 * Arguments:
 * 0: Code <CODE, STRING>
 *
 * Return Value:
 * Code <STRING>
 *
 * Public: Yes
 */
#include "script_component.hpp"

params ["_code"];
if (_code isEqualType "") exitWith {_code};

_code = str(_code);
_code = _code select [1, count _code - 2];

_code

