/*
 * Author: BaerMitUmlaut
 * Calculates the current metabolic costs for a unit.
 * Calculation is done according to the Pandolf/Wojtowicz formulas.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Speed <NUMBER>
 *
 * Return Value:
 * Metabolic cost <NUMBER>
 *
 * Example:
 * [player, 3.3] call ace_advanced_fatigue_fnc_getMetabolicCosts
 *
 * Public: No
 */
#include "script_component.hpp"
params ["_unit", "_velocity"];

private _virtualLoad = 0;
{
    _virtualLoad = _virtualLoad + (_x getVariable [QEGVAR(movement,vLoad), 0]);
} forEach [
    _unit,
    uniformContainer _unit,
    vestContainer _unit,
    backpackContainer _unit
];

private _gearMass = ((loadAbs _unit + _virtualLoad) * 0.1 / 2.2046) * GVAR(loadFactor);
private _terrainFactor = 1;
private _terrainAngle = asin (1 - ((surfaceNormal getPosASL _unit) select 2));
private _terrainGradient = (_terrainAngle / 45 min 1) * 5 * GVAR(terrainGradientFactor);
private _duty = GVAR(animDuty);

{
    if (_x isEqualType 0) then {
        _duty = _duty * _x;
    } else {
        _duty = _duty * (_unit call _x);
    };
} forEach (GVAR(dutyList) select 1);

if (GVAR(isSwimming)) then {
    _terrainGradient = 0;
};

if (_velocity > 2) then {
    (
        2.10 * SIM_BODYMASS
        + 4 * (SIM_BODYMASS + _gearMass) * ((_gearMass / SIM_BODYMASS) ^ 2)
        + _terrainFactor * (SIM_BODYMASS + _gearMass) * (0.90 * (_velocity ^ 2) + 0.66 * _velocity * _terrainGradient)
    ) * 0.23 * _duty
} else {
    (
        1.05 * SIM_BODYMASS
        + 4 * (SIM_BODYMASS + _gearMass) * ((_gearMass / SIM_BODYMASS) ^ 2)
        + _terrainFactor * (SIM_BODYMASS + _gearMass) * (1.15 * (_velocity ^ 2) + 0.66 * _velocity * _terrainGradient)
    ) * 0.23 * _duty
};
