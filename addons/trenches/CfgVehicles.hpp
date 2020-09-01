class CBA_Extended_EventHandlers;

class CfgVehicles {
    class Man;
    class CAManBase: Man {
        class ACE_SelfActions {
            class ACE_Equipment {
                class ACE_Trenches {
                    displayName = CSTRING(ActionCategory);
                    condition = QUOTE(_player call FUNC(canDigTrench) && GVAR(allowDigging));
                    statement = "";
                    exceptions[] = {"notOnMap", "isNotInside", "isNotSitting"};
                    showDisabled = 0;
                    priority = 3;
                    class GVAR(digEnvelopeSmall) {
                        displayName = CSTRING(DigEnvelopeSmall);
                        exceptions[] = {};
                        showDisabled = 0;
                        priority = 4;
                        statement = QUOTE([ARR_2({_this call FUNC(placeTrench)},[ARR_2(_this select 0,'ACE_envelope_small')])] call CBA_fnc_execNextFrame);
                        condition = QUOTE(([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench)) && GVAR(allowSmallEnvelope));
                    };
                    class GVAR(digEnvelopeBig): GVAR(digEnvelopeSmall) {
                        displayName = CSTRING(DigEnvelopeBig);
                        statement = QUOTE([ARR_2({_this call FUNC(placeTrench)},[ARR_2(_this select 0,'ACE_envelope_big')])] call CBA_fnc_execNextFrame);
                        condition = QUOTE(([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench)) && GVAR(allowBigEnvelope));
                    };
                    class GVAR(DigEnvelopeGigant): GVAR(digEnvelopeSmall) {
                        displayName = CSTRING(DigEnvelopeGigant);
                        statement = QUOTE([ARR_2({_this call FUNC(placeTrench)},[ARR_2(_this select 0,'ACE_envelope_gigant')])] call CBA_fnc_execNextFrame);
                        condition = QUOTE(([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench)) && GVAR(allowGigantEnvelope));
                    };
                    class GVAR(DigEnvelopeVehicle): GVAR(digEnvelopeSmall) {
                        displayName = CSTRING(DigEnvelopeVehicle);
                        statement = QUOTE([ARR_2({_this call FUNC(placeTrench)},[ARR_2(_this select 0,'ACE_envelope_vehicle')])] call CBA_fnc_execNextFrame);
                        condition = QUOTE(([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench)) && GVAR(allowVehicleEnvelope));
                    };
                    class GVAR(DigEnvelopeShort): GVAR(digEnvelopeSmall) {
                        displayName = CSTRING(DigEnvelopeShort);
                        statement = QUOTE([ARR_2({_this call FUNC(placeTrench)},[ARR_2(_this select 0,'ACE_envelope_short')])] call CBA_fnc_execNextFrame);
                        condition = QUOTE(([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench)) && GVAR(allowShortEnvelope));
                    };
                };
            };
        };
    };

    class BagFence_base_F;
    class ACE_envelope_small: BagFence_base_F {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(EnvelopeSmallName);
        descriptionShort = CSTRING(EnevlopeSmallDescription);
        model = QPATHTOF(data\trench_small.p3d);
        scope = 2;
        scopeCurator = 2;
        GVAR(diggingDuration) = QGVAR(smallEnvelopeDigDuration);
        GVAR(removalDuration) = QGVAR(smallEnvelopeRemoveDuration);
        GVAR(noGeoClass) = "ACE_envelope_small_NoGeo";
        GVAR(placementData)[] = {8,1.1,0};
        GVAR(grassCuttingPoints)[] = {{0,-0.5,0}};
        GVAR(isTrench) = 1;

        editorCategory = "EdCat_Things";
        editorSubcategory = "EdSubcat_Military";
        hiddenSelections[] = {"velka"};

        class GVAR(camouflagePositions) {
            center[] = {0, 1.3, 0};
            left[] = {1.3, -0.8, 0.4};
            right[] = {-1.3,-0.8,0.4};
        };

        class ACE_Actions {
            class ACE_MainActions {
                displayName = ECSTRING(interaction,MainAction);
                selection = "";
                distance = 3;
                condition = QUOTE(true);
                class GVAR(continueDigging) {
                    displayName = CSTRING(continueDiggingTrench);
                    condition = QUOTE([ARR_2(_target,_player)] call FUNC(canContinueDiggingTrench));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(continueDiggingTrench););
                    priority = -1;
                };
                class GVAR(remove) {
                    displayName = CSTRING(removeEnvelope);
                    condition = QUOTE([ARR_2(_target,_player)] call FUNC(canRemoveTrench));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(removeTrench););
                    priority = -1;
                };
                class GVAR(placeCamouflage) {
                    displayName = CSTRING(placeCamouflage);
                    condition = QUOTE([ARR_2(_target,_player)] call FUNC(canPlaceCamouflage));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(placeCamouflage));
                    priority = -1;
                };
                class GVAR(removeCamouflage) {
                    displayName = CSTRING(removeCamouflage);
                    condition = QUOTE([_target] call FUNC(canRemoveCamouflage));
                    statement = QUOTE([ARR_2(_target,_player)] call FUNC(removeCamouflage));
                    priority = -1;
                };
            };
        };

        class Attributes {
            class GVAR(camouflageAttribute) {
                control = "CheckboxNumber";
                defaultValue = "0";
                displayName = CSTRING(CamouflageAttribute);
                tooltip = CSTRING(CamouflageAttributeTooltip);
                expression = QUOTE([ARR_2(_this,_value)] call FUNC(applyCamouflageAttribute));
                property = CAMOUFLAGE_3DEN_ATTRIBUTE;
            };
        };

        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers {};
        };
    };
    class ACE_envelope_big: ACE_envelope_small {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(EnvelopeBigName);
        descriptionShort = CSTRING(EnevlopeBigDescription);
        model = QPATHTOF(data\trench_big.p3d);
        scope = 2;
        GVAR(diggingDuration) = QGVAR(bigEnvelopeDigDuration);
        GVAR(removalDuration) = QGVAR(bigEnvelopeRemoveDuration);
        GVAR(noGeoClass) = "ACE_envelope_big_NoGeo";
        GVAR(placementData)[] = {6,1.1,0.20};
        GVAR(grassCuttingPoints)[] = {{-1.5,-1,0},{1.5,-1,0}};

        class GVAR(camouflagePositions) {
            center[] = {-0.4, 0.4, 0.2};
            left[] = {-1.75, 0.2, 0.2};
            right[] = {1.75, 0.2, 0.2};
        };
    };
    class ACE_envelope_gigant: ACE_envelope_small {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(EnvelopeGigantName);
        descriptionShort = CSTRING(EnevlopeGigantDescription);
        GVAR(diggingDuration) = QGVAR(gigantEnvelopeDigDuration);
        GVAR(removalDuration) = QGVAR(gigantEnvelopeRemovalDuration);
        GVAR(noGeoClass) = "ACE_envelope_gigant_noGeo";
        GVAR(placementData)[] = {8,1.1,0.20};
        GVAR(grassCuttingPoints)[] = {{-1.5,-1,0},{1.5,-1,0}};
        model = QPATHTOF(data\trench_gigant.p3d);

        class GVAR(camouflagePositions) {
            left1[] = {-0.5, 0.3, 0.5};
            left2[] = {-2.7, 0.3, 0.5};
            right1[] = {2.7, 0.15, 0.35};
            right2[] = {4.9, -0.5, -0.15};
        };
    };
    class ACE_envelope_vehicle: ACE_envelope_small {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(EnvelopeVehicleName);
        descriptionShort = CSTRING(EnevlopeVehicleDescription);
        GVAR(diggingDuration) = QGVAR(vehicleEnvelopeDigDuration);
        GVAR(removalDuration) = QGVAR(vehicleEnvelopeRemovalDuration);
        GVAR(noGeoClass) = "ACE_envelope_vehicle_noGeo";
        GVAR(placementData)[] = {10,1.1,0.20};
        GVAR(grassCuttingPoints)[] = {{-1.5,-1,0},{1.5,-1,0}};
        model = QPATHTOF(data\trench_vehicle.p3d);

        class GVAR(camouflagePositions) {};
        class Attributes {};
    };
    class ACE_envelope_short: ACE_envelope_small {
        author = ECSTRING(common,ACETeam);
        displayName = CSTRING(EnvelopeShortName);
        descriptionShort = CSTRING(EnevlopeShortDescription);
        GVAR(diggingDuration) = QGVAR(shortEnvelopeDigDuration);
        GVAR(removalDuration) = QGVAR(shortEnvelopeRemovalDuration);
        GVAR(noGeoClass) = "ACE_envelope_short_noGeo";
        GVAR(placementData)[] = {10,1.1,0.20};
        GVAR(grassCuttingPoints)[] = {{-1.5,-1,0},{1.5,-1,0}};
        model = QPATHTOF(data\trench_short.p3d);

        class GVAR(camouflagePositions) {
            right[] = {1.1,0.2,0.2};
            left[] = {-1.1,0.1,0.2};
        };
    };

    class ACE_envelope_small_NoGeo: ACE_envelope_small {
        scope = 1;
        scopeCurator = 0;
        model = QPATHTOF(data\trench_small_nogeo.p3d);
    };
    class ACE_envelope_big_NoGeo: ACE_envelope_big {
        scope = 1;
        scopeCurator = 0;
        model = QPATHTOF(data\trench_big_nogeo.p3d);
    };
    class ACE_envelope_gigant_NoGeo: ACE_envelope_gigant {
        scope = 1;
        scopeCurator = 0;
        model = QPATHTOF(data\trench_gigant_nogeo.p3d);
    };
    class ACE_envelope_vehicle_NoGeo: ACE_envelope_vehicle {
        scope = 1;
        scopeCurator = 0;
        model = QPATHTOF(data\trench_vehicle_nogeo.p3d);
    };
    class ACE_envelope_short_NoGeo: ACE_envelope_short {
        scope = 1;
        scopeCurator = 0;
        model = QPATHTOF(data\trench_short_nogeo.p3d);
    };

    class Box_NATO_Support_F;
    class ACE_Box_Misc: Box_NATO_Support_F {
        class TransportItems {
            MACRO_ADDITEM(ACE_EntrenchingTool,50);
        };
    };
};
