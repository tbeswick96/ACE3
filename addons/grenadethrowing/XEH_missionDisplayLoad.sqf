#include "script_component.hpp"

params ["_display"];

_display displayAddEventHandler ["KeyDown", {_this call FUNC(onKeyDown)}];
_display displayAddEventHandler ["KeyUp", {_this call FUNC(onKeyUp)}];
_display displayAddEventHandler ["MouseButtonDown", {_this call FUNC(onMouseButtonDown)}];
_display displayAddEventHandler ["MouseZChanged", {_this call FUNC(onMouseScroll)}];
