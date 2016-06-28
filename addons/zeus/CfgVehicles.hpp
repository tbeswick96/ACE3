class CfgVehicles {
    class Module_F;
    class ModuleEmpty_F;
    class ACE_Module;

    class ModuleCurator_F: Module_F {
        function = QFUNC(bi_moduleCurator);
    };
    class ModuleMine_F: ModuleEmpty_F {
        function = QFUNC(bi_moduleMine);
    };
    class ModuleOrdnance_F: Module_F {
        function = QFUNC(bi_moduleProjectile);
    };
    class ModuleRemoteControl_F: Module_F {
        function = QFUNC(bi_moduleRemoteControl);
    };
    class GVAR(moduleSettings): ACE_Module {
        scope = 2;
        displayName = CSTRING(Settings_DisplayName);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Settings_ca.paa);
        category = "ACE";
        function = QFUNC(moduleZeusSettings);
        functionPriority = 1;
        isGlobal = 1;
        isSingular = 1;
        isTriggerActivated = 0;
        author = ECSTRING(common,ACETeam);
        class Arguments {
            class zeusAscension {
                displayName = CSTRING(ascension_DisplayName);
                description = CSTRING(ascension_Description);
                typeName = "BOOL";
                defaultValue = 0;
            };
            class zeusBird {
                displayName = CSTRING(bird_DisplayName);
                description = CSTRING(bird_Description);
                typeName = "BOOL";
                defaultValue = 0;
            };
            class remoteWind {
                displayName = CSTRING(remoteWind_DisplayName);
                description = CSTRING(remoteWind_Description);
                typeName = "BOOL";
                defaultValue = 0;
            };
            class radioOrdnance {
                displayName = CSTRING(radioOrdnance_DisplayName);
                description = CSTRING(radioOrdnance_Description);
                typeName = "BOOL";
                defaultValue = 0;
            };
            class revealMines {
                displayName = CSTRING(revealMines_DisplayName);
                description = CSTRING(revealMines_Description);
                typeName = "NUMBER";
                class values {
                    class disable {
                        name = "$STR_A3_OPTIONS_DISABLED";
                        value = 0;
                        default = 1;
                    };
                    class partial {
                        name = CSTRING(revealMines_partial);
                        value = 1;
                    };
                    class full  {
                        name = CSTRING(revealMines_full);
                        value = 2;
                    };
                };
            };
            class autoAddObjects {
                displayName = CSTRING(AddObjectsToCurator);
                description = CSTRING(AddObjectsToCurator_desc);
                typeName = "BOOL";
                defaultValue = 0;
            };
        };
        class ModuleDescription {
            description = CSTRING(Settings_Description);
            sync[] = {};
        };
    };
    class GVAR(moduleBase): Module_F {
        author = ECSTRING(common,ACETeam);
        category = "ACE";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        scope = 1;
        scopeCurator = 2;
    };
    class GVAR(moduleAddSpareTrack): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleAddSpareTrack_DisplayName);
        function = QFUNC(moduleAddSpareTrack);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Medic_ca.paa);//@todo
    };
    class GVAR(moduleAddSpareWheel): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleAddSpareWheel_DisplayName);
        function = QFUNC(moduleAddSpareWheel);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Medic_ca.paa);//@todo
    };
    class GVAR(moduleCaptive): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleCaptive_DisplayName);
        function = QFUNC(moduleCaptive);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Captive_ca.paa);
    };
    class GVAR(moduleDefendArea): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleDefendArea_DisplayName);
        curatorInfoType = QGVAR(RscDefendArea);
    };
    class GVAR(moduleGlobalSetSkill): GVAR(moduleBase) {
        displayName = CSTRING(ModuleGlobalSetSkill_DisplayName);
        curatorInfoType = QGVAR(RscGlobalSetSkill);
    };
    class GVAR(moduleGroupSide): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleGroupSide_DisplayName);
        curatorInfoType = QGVAR(RscGroupSide);
    };
    class GVAR(modulePatrolArea): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModulePatrolArea_DisplayName);
        curatorInfoType = QGVAR(RscPatrolArea);
    };
    class GVAR(moduleSearchArea): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSearchArea_DisplayName);
        curatorInfoType = QGVAR(RscSearchArea);
    };
    class GVAR(moduleSearchNearby): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSearchNearby_DisplayName);
        function = QFUNC(moduleSearchNearby);
    };
    class GVAR(moduleSetMedic): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSetMedic_DisplayName);
        function = QFUNC(moduleSetMedic);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Medic_ca.paa);
    };
    class GVAR(moduleSetMedicalFacility): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSetMedicalFacility_DisplayName);
        function = QFUNC(moduleSetMedicalFacility);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Medic_ca.paa);
    };
    class GVAR(moduleSetMedicalVehicle): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSetMedicalVehicle_DisplayName);
        function = QFUNC(moduleSetMedicalVehicle);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Medic_ca.paa);
    };
    class GVAR(moduleSurrender): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleSurrender_DisplayName);
        function = QFUNC(moduleSurrender);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Surrender_ca.paa);
    };
    class GVAR(moduleTeleportPlayers): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleTeleportPlayers_DisplayName);
        curatorInfoType = QGVAR(RscTeleportPlayers);
    };
    class GVAR(moduleUnconscious): GVAR(moduleBase) {
        curatorCanAttach = 1;
        displayName = CSTRING(ModuleUnconscious_DisplayName);
        function = QFUNC(moduleUnconscious);
        icon = QPATHTOF(UI\Icon_Module_Zeus_Unconscious_ca.paa);
    };
};
