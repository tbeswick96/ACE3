#include "..\script_component.hpp"
/*
 * Author: tcvm
 * Condition to switch to next navigation profile
 *
 * Arguments:
 * Guidance Arg Array <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call ace_hellfire_fnc_midCourseTransition
 *
 * Public: No
 */

params ["_args", "_timestep"];
_args params ["_firedEH", "_launchParams", "_flightParams", "_seekerParams", "_stateParams", "_targetData", "_navigationStateData"];
_firedEH params ["_shooter","","","","_ammo","","_projectile"];
_launchParams params ["_shooter","_targetLaunchParams","_seekerType","_attackProfile","_lockMode","_laserInfo","_navigationType"];
_targetLaunchParams params ["_target", "_targetPos", "_launchPos", "_launchDir", "_launchTime"];
_flightParams params ["_pitchRate", "_yawRate", "_isBangBangGuidance"];
_stateParams params ["_lastRunTime", "_seekerStateParams", "_attackProfileStateParams", "_lastKnownPosState","_navigationParams", "_guidanceParameters"];
_seekerParams params ["_seekerAngle", "_seekerAccuracy", "_seekerMaxRange", "_seekerMinRange"];
_targetData params ["_targetDirection", "_attackProfileDirection", "_targetRange", "_targetVelocity", "_targetAcceleration"];

_attackProfileStateParams params ["_state"];

if (_state isNotEqualTo STAGE_ATTACK_TERMINAL) exitWith { false };

// Don't switch to ZEM until missile is roughly aligned with the target.
// ZEM gives wrong corrections when the missile is far off-axis (e.g. drone launch
// where the missile is heading perpendicular to the target direction).
private _velocityDir = vectorNormalized velocity _projectile;
private _angleOff = acos (_velocityDir vectorCos _attackProfileDirection);
_angleOff < 30
