#include "\a3\ui_f\hpp\defineDIKCodes.inc"

["ACE3 Common", QGVAR(toggleHide), "Toggle Uncon Dialog", {
    if (!GVAR(enabled)) exitWith {false};
    if (!alive ACE_player) exitWith {false};
    if (!(ACE_player getVariable ["ACE_isUnconscious", false])) exitWith {false};

    if (isNull findDisplay IDD_UNCON) then {
        [] call FUNC(openDialog);
    } else {
        [] call FUNC(closeDialog);
    };
    true
}, {false}, [DIK_H, [false, false, true]]] call CBA_fnc_addKeybind;
