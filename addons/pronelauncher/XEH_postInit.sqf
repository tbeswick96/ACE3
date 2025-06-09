#include "script_component.hpp"

if (hasInterface) exitWith {
    addUserActionEventHandler ["Prone", "Activate", { 
        if ((!alive ACE_player) || {!(isNull objectParent ACE_player)}) exitWith {};
        private _launcherWeapon = secondaryWeapon ACE_player;
        if ((_launcherWeapon == "") || {currentWeapon ACE_player != _launcherWeapon}) exitWith {};

        ACE_player playMoveNow "ACE_LauncherProne";
    }];

    addUserActionEventHandler ["moveUp", "Activate", { // (X) Crouch / Stand Up
        if ((!alive ACE_player) || {!(isNull objectParent ACE_player)}) exitWith {};
        private _launcherWeapon = secondaryWeapon ACE_player;
        if ((_launcherWeapon == "") || {currentWeapon ACE_player != _launcherWeapon}) exitWith {};

        if ((stance ACE_player) == "PRONE") then {
            ACE_player playMoveNow "AmovPpneMstpSrasWlnrDnon_AmovPknlMstpSrasWlnrDnon";
        };
    }];

    addUserActionEventHandler ["MoveDown", "Activate", { // (Z) Go Prone / Stand Up
        if ((!alive ACE_player) || {!(isNull objectParent ACE_player)}) exitWith {};
        private _launcherWeapon = secondaryWeapon ACE_player;
        if ((_launcherWeapon == "") || {currentWeapon ACE_player != _launcherWeapon}) exitWith {};

        if ((stance ACE_player) == "PRONE") then {
            ACE_player playMoveNow "AmovPpneMstpSrasWlnrDnon_AmovPknlMstpSrasWlnrDnon";
            ACE_player playMove "AmovPknlMstpSrasWlnrDnon_AmovPercMstpSrasWlnrDnon";
        } else {
            ACE_player playMoveNow "ACE_LauncherProne";
        }
    }];
};
