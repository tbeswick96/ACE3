/*
 * Author: Glowbal, Ruthberg
 * Module for adjusting the scopes settings
 *
 * Arguments:
 * 0: The module logic <LOGIC>
 * 1: units <ARRAY>
 * 2: activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_logic","_units", "_activated"];

if !(_activated) exitWith {};
    
[_logic, QGVAR(enabled), "enabled"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(forceUseOfAdjustmentTurrets), "forceUseOfAdjustmentTurrets"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(defaultZeroRange), "defaultZeroRange"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(zeroReferenceTemperature), "zeroReferenceTemperature"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(zeroReferenceBarometricPressure), "zeroReferenceBarometricPressure"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(zeroReferenceHumidity), "zeroReferenceHumidity"] call EFUNC(common,readSettingFromModule);
[_logic, QGVAR(deduceBarometricPressureFromTerrainAltitude), "deduceBarometricPressureFromTerrainAltitude"] call EFUNC(common,readSettingFromModule);

GVAR(defaultZeroRange) = 0 max GVAR(defaultZeroRange) min 1000;
GVAR(zeroReferenceTemperature) = -55 max GVAR(zeroReferenceTemperature) max 55;
GVAR(zeroReferenceBarometricPressure) = 0 max GVAR(zeroReferenceBarometricPressure) min 1013.25;
GVAR(zeroReferenceHumidity) = 0 max GVAR(zeroReferenceHumidity) min 1.0;

if (GVAR(deduceBarometricPressureFromTerrainAltitude)) then {
    GVAR(zeroReferenceBarometricPressure)  = 1013.25 * (1 - (0.0065 * EGVAR(common,mapAltitude)) / 288.15) ^ 5.255754495;
};