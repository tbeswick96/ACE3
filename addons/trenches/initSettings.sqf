[QGVAR(allowDigging), "CHECKBOX", [LSTRING(settingAllowDigging_displayName), LSTRING(settingAllowDigging_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(allowCamouflage), "CHECKBOX", [LSTRING(settingAllowCamouflage_displayName), LSTRING(settingAllowCamouflage_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(digRequireEntrenchmentTool), "CHECKBOX", [LSTRING(settingDigRequireEntrenchmentTool_displayName), LSTRING(settingDigRequireEntrenchmentTool_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(camouflageRequireEntrenchmentTool), "CHECKBOX", [LSTRING(settingCamouflageRequireEntrenchmentTool_displayName), LSTRING(settingCamouflageRequireEntrenchmentTool_tooltip)], LSTRING(Category), false] call CBA_fnc_addSetting;
[QGVAR(buildFatigueFactor), "SLIDER", [LSTRING(settingBuildFatigueFactor_displayName), LSTRING(settingBuildFatigueFactor_tooltip)], LSTRING(Category), [0, 5, 1, 1]] call CBA_fnc_addSetting;

[QGVAR(allowSmallEnvelope), "CHECKBOX", [LSTRING(allowSmallEnvelope_displayName), LSTRING(allowSmallEnvelope_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(allowBigEnvelope), "CHECKBOX", [LSTRING(allowBigEnvelope_displayName), LSTRING(allowBigEnvelope_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(allowGigantEnvelope), "CHECKBOX", [LSTRING(allowGigantEnvelope_displayName), LSTRING(allowGigantEnvelope_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(allowVehicleEnvelope), "CHECKBOX", [LSTRING(allowVehicleEnvelope_displayName), LSTRING(allowVehicleEnvelope_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;
[QGVAR(allowShortEnvelope), "CHECKBOX", [LSTRING(allowShortEnvelope_displayName), LSTRING(allowShortEnvelope_tooltip)], LSTRING(Category), true] call CBA_fnc_addSetting;

[QGVAR(smallEnvelopeDigDuration), "TIME", LSTRING(STR_ACE_Trenches_SmallEnvelopeDigDuration), LSTRING(Category), [5, 300, 20], true] call CBA_fnc_addSetting;
[QGVAR(smallEnvelopeRemovalDuration), "TIME", LSTRING(STR_ACE_Trenches_SmallEnvelopeDigDuration), LSTRING(Category), [5, 300, 12], true] call CBA_fnc_addSetting;
[QGVAR(bigEnvelopeDigDuration), "TIME", LSTRING(STR_ACE_Trenches_BigEnvelopeDigDuration), LSTRING(Category), [5, 300, 25], true] call CBA_fnc_addSetting;
[QGVAR(bigEnvelopeRemovalDuration), "TIME", LSTRING(STR_ACE_Trenches_BigEnvelopeDigDuration), LSTRING(Category), [5, 300, 15], true] call CBA_fnc_addSetting;
[QGVAR(gigantEnvelopeDigDuration), "TIME", LSTRING(STR_ACE_Trenches_GigantEnvelopeDigDuration), LSTRING(Category), [5, 300, 30], true] call CBA_fnc_addSetting;
[QGVAR(gigantEnvelopeRemovalDuration), "TIME", LSTRING(STR_ACE_Trenches_GigantEnvelopeDigDuration), LSTRING(Category), [5, 300, 20], true] call CBA_fnc_addSetting;
[QGVAR(vehicleEnvelopeDigDuration), "TIME", LSTRING(STR_ACE_Trenches_VehicleEnvelopeDigDuration), LSTRING(Category), [5, 300, 60], true] call CBA_fnc_addSetting;
[QGVAR(vehicleEnvelopeRemovalDuration), "TIME", LSTRING(STR_ACE_Trenches_VehicleEnvelopeDigDuration), LSTRING(Category), [5, 300, 30], true] call CBA_fnc_addSetting;
[QGVAR(shortEnvelopeDigDuration), "TIME", LSTRING(STR_ACE_Trenches_ShortEnvelopeDigDuration), LSTRING(Category), [5, 300, 15], true] call CBA_fnc_addSetting;
[QGVAR(shortEnvelopeRemovalDuration), "TIME", LSTRING(STR_ACE_Trenches_ShortEnvelopeDigDuration), LSTRING(Category), [5, 300, 10], true] call CBA_fnc_addSetting;
