[QGVAR(allowDigging), "CHECKBOX", [localize LSTRING(settingAllowDigging_displayName), localize LSTRING(settingAllowDigging_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(allowCamouflage), "CHECKBOX", [localize LSTRING(settingAllowCamouflage_displayName), localize LSTRING(settingAllowCamouflage_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(digRequireEntrenchmentTool), "CHECKBOX", [localize LSTRING(settingDigRequireEntrenchmentTool_displayName), localize LSTRING(settingDigRequireEntrenchmentTool_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(camouflageRequireEntrenchmentTool), "CHECKBOX", [localize LSTRING(settingCamouflageRequireEntrenchmentTool_displayName), localize LSTRING(settingCamouflageRequireEntrenchmentTool_tooltip)], localize LSTRING(settingCategory), false] call CBA_Settings_fnc_init;
[QGVAR(buildFatigueFactor), "SLIDER", [localize LSTRING(settingBuildFatigueFactor_displayName), localize LSTRING(settingBuildFatigueFactor_tooltip)], localize LSTRING(settingCategory), [0, 5, 1, 1]] call CBA_Settings_fnc_init;

[QGVAR(allowSmallEnvelope), "CHECKBOX", [localize LSTRING(allowSmallEnvelope_displayName), localize LSTRING(allowSmallEnvelope_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(allowBigEnvelope), "CHECKBOX", [localize LSTRING(allowBigEnvelope_displayName), localize LSTRING(allowBigEnvelope_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(allowGigantEnvelope), "CHECKBOX", [localize LSTRING(allowGigantEnvelope_displayName), localize LSTRING(allowGigantEnvelope_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(allowVehicleEnvelope), "CHECKBOX", [localize LSTRING(allowVehicleEnvelope_displayName), localize LSTRING(allowVehicleEnvelope_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;
[QGVAR(allowShortEnvelope), "CHECKBOX", [localize LSTRING(allowShortEnvelope_displayName), localize LSTRING(allowShortEnvelope_tooltip)], localize LSTRING(settingCategory), true] call CBA_Settings_fnc_init;

[QGVAR(smallEnvelopeDigDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_SmallEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 20, 0], true] call CBA_Settings_fnc_init;
[QGVAR(smallEnvelopeRemovalDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_SmallEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 12, 0], true] call CBA_Settings_fnc_init;
[QGVAR(bigEnvelopeDigDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_BigEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 25, 0], true] call CBA_Settings_fnc_init;
[QGVAR(bigEnvelopeRemovalDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_BigEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 15, 0], true] call CBA_Settings_fnc_init;
[QGVAR(gigantEnvelopeDigDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_GigantEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 30, 0], true] call CBA_Settings_fnc_init;
[QGVAR(gigantEnvelopeRemovalDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_GigantEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 20, 0], true] call CBA_Settings_fnc_init;
[QGVAR(vehicleEnvelopeDigDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_VehicleEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 60, 0], true] call CBA_Settings_fnc_init;
[QGVAR(vehicleEnvelopeRemovalDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_VehicleEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 30, 0], true] call CBA_Settings_fnc_init;
[QGVAR(shortEnvelopeDigDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_ShortEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 15, 0], true] call CBA_Settings_fnc_init;
[QGVAR(shortEnvelopeRemovalDuration), "SLIDER", localize LSTRING(STR_ACE_Trenches_ShortEnvelopeDigDuration), localize LSTRING(settingCategory), [5, 300, 10, 0], true] call CBA_Settings_fnc_init;
