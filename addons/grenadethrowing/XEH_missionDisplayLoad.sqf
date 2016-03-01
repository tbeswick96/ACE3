#include "script_component.hpp"

params ["_display"];

_display displayAddEventHandler ["MouseButtonDown", {_this call FUNC(onMouseButtonDown)}];
_display displayAddEventHandler ["MouseZChanged", {_this call FUNC(onMouseScroll)}];
