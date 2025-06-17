#include "script_component.hpp"

["CBA_settingsInitialized", {
    TRACE_2("settingsInit eh",GVAR(backblastDistanceCoefficient),GVAR(overpressureDistanceCoefficient));

    ["ace_overpressure", LINKFUNC(overpressureDamage)] call CBA_fnc_addEventHandler;

    // Register fire event handlers
    if (GVAR(backblastDistanceCoefficient) > 0) then {
        // ["ace_firedPlayer", LINKFUNC(firedEHBB)] call CBA_fnc_addEventHandler;
        ["ace_firedPlayer", {
            params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
            TRACE_1("firedPlayerEH:",_this);

            if (isNull objectParent _unit) then {
                TRACE_1("using bb:",_this);
                call FUNC(firedEHBB);
            } else {
                TRACE_1("using op:",_this);
                call FUNC(firedEHOP);
            };
        }] call CBA_fnc_addEventHandler;
    };
    if (GVAR(overpressureDistanceCoefficient) > 0 || {GVAR(backblastDistanceCoefficient) > 0}) then {
        ["ace_firedPlayerVehicle", { //IGNORE_PRIVATE_WARNING ["_weapon"];
            TRACE_1("firedPlayerVehicleEH:",_this);
            if (getNumber (configFile >> "CfgWeapons" >> _weapon >> QGVAR(backblast)) == 1) then {
                TRACE_1("using bb:",_this);
                call FUNC(firedEHBB);
            } else {
                TRACE_1("using op:",_this);
                call FUNC(firedEHOP);
            };
        }] call CBA_fnc_addEventHandler;
    };

    GVAR(cacheHash) = createHashMap;
}] call CBA_fnc_addEventHandler;
