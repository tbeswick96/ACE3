#include "script_component.hpp"

params ["_display"];

_display displayAddEventHandler ["MouseButtonDown", {_this call FUNC(onMouseButtonDown)}];
_display displayAddEventHandler ["MouseZChanged", {_this call FUNC(onMouseScroll)}];


//@todo, remove all lines with comments after CBA update, events rewrite branch
// note 2, will break in save games after ~ 10 seconds thanks to CBA, fixed with below
_this spawn {//
    waitUntil {!isNull findDisplay 46};//
    sleep 2;//

    params ["_display"];//

    _display displayAddEventHandler ["KeyDown", {_this call FUNC(onKeyDown)}];
};//
