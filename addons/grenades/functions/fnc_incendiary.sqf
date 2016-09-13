/*
 * Author: commy2
 * Makes incendiary burn.
 *
 * Arguments:
 * 0: The grenade <OBJECT>
 * 1: Incendiary lifetime <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_nade, 60] call ace_grenades_fnc_incendiary
 *
 * Public: No
 */
#include "script_component.hpp"

#define PARTICLE_LIFE_TIME 2
#define PARTICLE_DENSITY 20
#define PARTICLE_SIZE 1
#define PARTICLE_SPEED 1

#define PARTICLE_SMOKE_LIFE_TIME 5
#define PARTICLE_SMOKE_DENSITY 5
#define PARTICLE_SMOKE_SIZE 0.5
#define PARTICLE_SMOKE_SPEED 1
#define PARTICLE_SMOKE_LIFTING 1
#define PARTICLE_SMOKE_WIND_EFFECT 1

#define EFFECT_SIZE 1
#define ORIENTATION 5.4
#define EXPANSION 1

params ["_projectile", "_timeToLive"];

private _position = position _projectile;

// --- fire
private _fire = "#particlesource" createVehicleLocal _position;

_fire setParticleParams [
    ["\A3\data_f\ParticleEffects\Universal\Universal",16,10,32],
    "",
    "billboard",
    1,
    PARTICLE_LIFE_TIME,
    [0,0,0],
    [0, 0, 0.4 * PARTICLE_SPEED],
    0,
    0.0565,
    0.05,
    0.03,
    [0.9 * PARTICLE_SIZE, 0],
    [
        [0.5,0.5,0.5,-0],
        [0.5,0.5,0.5,-1],
        [0.5,0.5,0.5,-1],
        [0.5,0.5,0.5,-1],
        [0.5,0.5,0.5,-1],
        [0.5,0.5,0.5,0]
    ],
    [1],
    0.01,
    0.02,
    "",
    "",
    _projectile,
    ORIENTATION,
    false,
    -1,
    [[3,3,3,0]]
];

_fire setParticleRandom [PARTICLE_LIFE_TIME / 4, [0.15 * EFFECT_SIZE, 0.15 * EFFECT_SIZE, 0], [0.2,0.2,0], 0.4, 0, [0,0,0,0], 0, 0, 0.2];
_fire setParticleFire [1.2,1.0,0.1];
_fire setDropInterval (1 / PARTICLE_DENSITY);

// --- smoke
private _smoke = "#particlesource" createVehicleLocal _position;

_smoke setParticleParams [
    ["\A3\data_f\ParticleEffects\Universal\Universal_02",8,0,40,1],
    "",
    "billboard",
    1,
    PARTICLE_SMOKE_LIFE_TIME,
    [0,0,0],
    [0, 0, 2 * PARTICLE_SMOKE_SPEED],
    0,
    0.05,
    0.04 * PARTICLE_SMOKE_LIFTING,
    0.05 * PARTICLE_SMOKE_WIND_EFFECT,
    [1 * PARTICLE_SMOKE_SIZE + 1, 1.8 * PARTICLE_SMOKE_SIZE + 15],
    [
        [0.7,0.7,0.7,0.7],
        [0.7,0.7,0.7,0.6],
        [0.7,0.7,0.7,0.45],
        [0.84,0.84,0.84,0.28],
        [0.84,0.84,0.84,0.16],
        [0.84,0.84,0.84,0.09],
        [0.84,0.84,0.84,0.06],
        [1,1,1,0.02],
        [1,1,1,0]
    ],
    [1,0.55,0.35],
    0.1,
    0.08 * EXPANSION,
    "",
    "",
    _projectile
];

_smoke setParticleRandom [PARTICLE_SMOKE_LIFE_TIME / 2, [0.5 * EFFECT_SIZE, 0.5 * EFFECT_SIZE, 0.2 * EFFECT_SIZE], [0.3,0.3,0.5], 1, 0, [0,0,0,0.06], 0, 0];
_smoke setDropInterval (1 / PARTICLE_SMOKE_DENSITY);

// --- light
private _light = "#lightpoint" createVehicleLocal (_position vectorAdd [0,0,0.5]);

_light setLightBrightness 1.0;
_light setLightColor [1,0.65,0.4];
_light setLightAmbient [0.15,0.05,0];
_light setLightIntensity (50 + 400 * ((PARTICLE_SIZE + EFFECT_SIZE) / 2));
_light setLightAttenuation [0,0,0,1];

_light setLightDayLight false;

_light lightAttachObject [_projectile, [0,0,0]];

// --- sound
private _sound = objNull;

if (isServer) then {
    _sound = createSoundSource ["Sound_Fire", _position, [], 0];
};

[{
    {deleteVehicle _x} forEach _this;
}, [_fire, _smoke, _light, _sound], _timeToLive] call CBA_fnc_waitAndExecute;

// --- damage
{
    if (local _x) then {
        //systemChat format ["burn: %1", _x];

        // --- destroy nearby static weapons and ammo boxes
        if (_x isKindOf "StaticWeapon" || {_x isKindOf "ReammoBox_F"}) then {
            _x setDamage 1;
        };

        // --- delete nearby ground weapon holders
        if (_x isKindOf "WeaponHolder" || {_x isKindOf "WeaponHolderSimulated"}) then {
            deleteVehicle _x;
        };

        // --- inflame fireplace, barrels etc.
        _x inflame true;
    };
} forEach (_position nearObjects EFFECT_SIZE);

// --- burn car engine
private _vehicle = _position nearestObject "Car";
if (!local _vehicle || {_vehicle isKindOf "Wheeled_APC_F"}) exitWith {};

private _engineSelection = getText (_vehicle call CBA_fnc_getObjectConfig >> "HitPoints" >> "HitEngine" >> "name");
private _enginePosition = _vehicle modelToWorld (_vehicle selectionPosition _engineSelection);

if (_position distance _enginePosition < EFFECT_SIZE * 2) then {
    _vehicle setHit [_engineSelection, 1];

    if ("ace_cookoff" call EFUNC(common,isModLoaded) && {EGVAR(cookoff,enable)}) then {
        _vehicle call EFUNC(cookoff,engineFire);
    };
};
