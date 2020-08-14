[
    QEGVAR(medical,bleedingCoefficient),
    "SLIDER",
    [LSTRING(BleedingCoefficient_DisplayName), LSTRING(BleedingCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    QEGVAR(medical,painCoefficient),
    "SLIDER",
    [LSTRING(PainCoefficient_DisplayName), LSTRING(PainCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    QEGVAR(medical,ivFlowRate),
    "SLIDER",
    [LSTRING(IvFlowRate_DisplayName), LSTRING(IvFlowRate_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    QEGVAR(medical,simplePAK),
    "SLIDER",
    ["Simple PAK Conditions", "Simplifies conditions for PAK use to only require stitched wounds"],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    false,
    true
] call CBA_settings_fnc_init;
