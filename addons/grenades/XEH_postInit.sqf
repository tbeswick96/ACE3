// by commy2

#include "script_component.hpp"

["ace_flashbangExploded", {_this call FUNC(flashbangExplosionEH)}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

GVAR(flashbangPPEffectCC) = ppEffectCreate ["ColorCorrections", 4265];
GVAR(flashbangPPEffectCC) ppEffectForceInNVG true;

// Add keybinds
["ACE3 Weapons", QGVAR(switchGrenadeMode), localize LSTRING(SwitchGrenadeMode), {
    // Conditions: canInteract
    if !([ACE_player, objNull, ["isNotEscorting"]] call EFUNC(common,canInteractWith)) exitWith {false};
    // Conditions: specific
    if (!([ACE_player] call CBA_fnc_canUseWeapon)) exitWith {false};
    // Don't change mode or show hint if advanced throwing is active
    if (ACE_player getVariable [QEGVAR(advanced_throwing,inHand), false]) exitWith {false};

    // Statement
    [] call FUNC(nextMode);
}, {false}, [9, [false, false, false]], false] call CBA_fnc_addKeybind; //8 Key

// Register fire event handler
["ace_firedPlayer", DFUNC(throwGrenade)] call CBA_fnc_addEventHandler;
["ace_firedPlayerNonLocal", DFUNC(throwGrenade)] call CBA_fnc_addEventHandler;
["ace_firedNonPlayer", DFUNC(throwGrenade)] call CBA_fnc_addEventHandler;
