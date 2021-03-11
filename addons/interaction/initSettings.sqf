[
    QGVAR(enableTeamManagement), "CHECKBOX",
    [LSTRING(EnableTeamManagement_DisplayName), LSTRING(EnableTeamManagement_Description)],
    format ["ACE %1", LLSTRING(DisplayName)],
    true,
    true
] call CBA_fnc_addSetting;

[
    QGVAR(enableMagazinePassing), "CHECKBOX",
    LSTRING(PassMagazineSetting),
    format ["ACE %1", LLSTRING(DisplayName)],
    true
] call CBA_fnc_addSetting;

[
    QGVAR(disableNegativeRating), "CHECKBOX",
    [LSTRING(DisableNegativeRating_DisplayName), LSTRING(DisableNegativeRating_Description)],
    format ["ACE %1", LLSTRING(DisplayName)],
    false,
    true,
    {[QGVAR(disableNegativeRating), _this] call EFUNC(common,cbaSettings_settingChanged)},
    true
] call CBA_fnc_addSetting;

[
    QGVAR(enableWeaponAttachments), "CHECKBOX",
    ["str_a3_cfgeditorcategories_edcat_weaponattachments0", LSTRING(weaponAttachments_Description)],
    format ["ACE %1", LLSTRING(DisplayName)],
    true
] call CBA_fnc_addSetting;
