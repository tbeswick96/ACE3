#include "script_component.hpp"

["ace_settingsInitialized", {
    if (!GVAR(enableLoadoutMenu)) exitWith {};

    private _aircraftWithPylons = ("isClass (_x >> 'Components' >> 'TransportPylonsComponent')" configClasses (configFile >> "CfgVehicles"));
    {
        [configName _x, "init", {
            params ["_aircraft"];

            if (_aircraft getVariable [QGVAR(actionAdded), false]) exitWith {};

            private _loadoutAction = [
                QGVAR(loadoutAction),
                localize LSTRING(ConfigurePylons),
                "",
                {[_target] call FUNC(showDialog)},
                {
                    private _rearmVehicles = _target nearObjects ["LandVehicle", AIRCRAFT_ACTION_DISTANCE + 10];
                    if (["ace_rearm"] call EFUNC(common,isModLoaded)) then {
                        _rearmVehicles = _rearmVehicles select {isNumber (configFile >> "CfgVehicles" >> typeOf _x >> QEGVAR(rearm,defaultSupply))};
                    } else {
                        _rearmVehicles = _rearmVehicles select {getAmmoCargo _x > 0};
                    };

                    ({([_x, _target] call EFUNC(interaction,getInteractionDistance)) < AIRCRAFT_ACTION_DISTANCE} count _rearmVehicles) > 0
                }
            ] call EFUNC(interact_menu,createAction);
            
            [_aircraft, 0, ["ACE_MainActions"], _loadoutAction] call EFUNC(interact_menu,addActionToObject);
            _aircraft setVariable [QGVAR(actionAdded), true, true];
        }, true, [], true] call CBA_fnc_addClassEventHandler;
        false
    } count _aircraftWithPylons;
}] call CBA_fnc_addEventHandler;

[QGVAR(onButtonApplyLocal), LINKFUNC(onButtonApplyLocal)] call CBA_fnc_addEventHandler;
