#include "..\script_component.hpp"
/*
 * Author: UKSF
 * Transition condition for cruise missile seeker switch: GPS -> SALH.
 * Transitions when the cruise missile attack profile enters popup or terminal phase.
 *
 * Arguments:
 * 0: Guidance Arg Array <ARRAY>
 * 1: Timestep <NUMBER>
 *
 * Return Value:
 * Should transition <BOOL>
 *
 * Example:
 * [_args, 0.1] call ace_missileguidance_fnc_cruiseMissile_seekerTransition
 *
 * Public: No
 */

params ["_args"];
_args params ["", "", "", "", "_stateParams"];
_stateParams params ["", "", "_attackProfileStateParams"];

// cruise_missile_defines.hpp: STAGE_POPUP = 5, STAGE_TERMINAL = 6
private _stage = _attackProfileStateParams param [0, 0];

// Transition when entering popup or terminal phase
_stage >= 5
