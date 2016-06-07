//by commy2
#include "script_component.hpp"

if (!hasInterface) exitWith {};

["playerChanged", FUNC(handleVirtualMass)] call FUNC(addEventHandler);
["playerInventoryChanged", FUNC(handleVirtualMass)] call FUNC(addEventHandler);

["ACE3 Movement", QGVAR(climb), localize LSTRING(Climb), {
    // Conditions: canInteract
    if !([ACE_player, objNull, []] call EFUNC(common,canInteractWith)) exitWith {false};
    // Conditions: specific
    if (ACE_player != (vehicle ACE_player)) exitWith {false};

    // Statement
    [ACE_player] call FUNC(climb);
    true
},
{false},
[47, [false, true, false]], false] call CBA_fnc_addKeybind; //DIK_V + CTRL//STRG
