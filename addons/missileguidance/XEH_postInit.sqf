#include "script_component.hpp"
#include "\a3\ui_f\hpp\defineDIKCodes.inc"

[QGVAR(handoff), LINKFUNC(handleHandoff)] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Persistent debug draws — populated by fnc_proximityCheck on detonation /
// direct-hit skip events. Each entry: [_expireTime, _drawCallback, _drawArgs].
// PFEH calls each entry every frame and removes after expiry.
GVAR(proxDebug_pendingDraws) = [];
[{
    GVAR(proxDebug_pendingDraws) = GVAR(proxDebug_pendingDraws) select {
        _x params ["_expireTime", "_drawCallback", "_drawArgs"];
        private _stillAlive = CBA_missionTime <= _expireTime;
        if (_stillAlive) then {
            _drawArgs call _drawCallback;
        };
        _stillAlive
    };
}, 0, []] call CBA_fnc_addPerFrameHandler;

["ACE3 Weapons", QGVAR(cycleFireMode), LLSTRING(CycleFireMode), {
    [] call FUNC(cycleAttackProfileKeyDown)
}, {
}, [DIK_TAB, [false, true, false]], false] call CBA_fnc_addKeybind;  //Ctrl+Tab Key

["ACE3 Weapons", QGVAR(cycleSeekerType), LLSTRING(CycleSeekerType), {
    [] call FUNC(cycleSeekerType)
}, {
}, [], false] call CBA_fnc_addKeybind;

["up", {
    [[0, 0, 1], ACE_player] call FUNC(MCLOS_buttonPressed)
}, {
    [[0, 0, -1], ACE_player] call FUNC(MCLOS_buttonPressed)
}] call FUNC(keybind_add);
["down", {
    [[0, 0, -1], ACE_player] call FUNC(MCLOS_buttonPressed)
}, {
    [[0, 0, 1], ACE_player] call FUNC(MCLOS_buttonPressed)
}] call FUNC(keybind_add);
["left", {
    [[-1, 0, 0], ACE_player] call FUNC(MCLOS_buttonPressed)
}, {
    [[1, 0, 0], ACE_player] call FUNC(MCLOS_buttonPressed)
}] call FUNC(keybind_add);
["right", {
    [[1, 0, 0], ACE_player] call FUNC(MCLOS_buttonPressed)
}, {
    [[-1, 0, 0], ACE_player] call FUNC(MCLOS_buttonPressed)
}] call FUNC(keybind_add);

{
    _y params ["", "", "_defaultBind", "_displayName"];
    private _name = format [QGVAR(%1), _x];
    ["ACE3 Weapons", _name, _displayName,
        compile format ['["%1", "down"] call FUNC(keybind_pressed)', _x],
        compile format ['["%1", "up"] call FUNC(keybind_pressed)', _x],
        _defaultBind
    ] call CBA_fnc_addKeybind;
} forEach GVAR(keybinds);

["ace_settingsInitialized", {
    ["turret", LINKFUNC(gps_setupVehicle), false] call CBA_fnc_addPlayerEventHandler;
    ["vehicle", LINKFUNC(gps_setupVehicle), true] call CBA_fnc_addPlayerEventHandler; // only one of these needs the retro flag

    // Seeker type interact actions
    ["turret", LINKFUNC(setupSeekerActions), false] call CBA_fnc_addPlayerEventHandler;
    ["vehicle", LINKFUNC(setupSeekerActions), true] call CBA_fnc_addPlayerEventHandler;

    // Add UAV Control Compatibility
    ["ACE_controlledUAV", {
        params ["_UAV", "_seatAI", "_turret", "_position"];
        TRACE_4("ACE_controlledUAV EH",_UAV,_seatAI,_turret,_position);
        if (!isNull _seatAI) then {
            [_seatAI] call FUNC(gps_setupVehicle);
        };
    }] call CBA_fnc_addEventHandler;
}] call CBA_fnc_addEventHandler;

// MCLOS - Mouse Input
["lock", {
    if (GVAR(MCLOS_mouseInput)) exitWith { GVAR(MCLOS_mouseInput) = false; };
    GVAR(MCLOS_mouseInput) = true;
    call FUNC(MCLOS_mouseInput);
}, {
    GVAR(MCLOS_mouseInput) = false;
}] call EFUNC(missileguidance,keybind_add);
