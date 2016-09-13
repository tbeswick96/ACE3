
class CfgWeapons {
    class Pistol_Base_F;
    class Rifle_Base_F;
    class srifle_EBR_F;
    class launch_O_Titan_F;
    class UGL_F;
    
    class GM6_base_F;
    class rhs_weap_M107_Base_F: GM6_base_F {
        ACE_barrelTwist = 381.0;
        ACE_barrelLength = 736.6;
    };
    class rhs_weap_XM2010_Base_F: Rifle_Base_F {
        ACE_barrelTwist = 254.0;
        ACE_barrelLength = 609.6;
        ACE_Overheating_dispersion = 0.75;
    };
    class rhs_weap_m24sws : rhs_weap_XM2010_Base_F {
        ACE_barrelTwist = 285.75;
        ACE_barrelLength = 609.6;
    };
    class arifle_MX_Base_F;
    class rhs_weap_m4_Base: arifle_MX_Base_F {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 368.3;
        class M203_GL: UGL_F {
            magazines[] = {
                "rhs_mag_M441_HE",
                "rhs_mag_M433_HEDP",
                "rhs_mag_M4009",
                "rhs_mag_m576",
                "rhs_mag_M585_white",
                "rhs_mag_M661_green",
                "rhs_mag_M662_red",
                "rhs_mag_M713_red",
                "rhs_mag_M714_white",
                "rhs_mag_M715_green",
                "rhs_mag_M716_yellow",

                // bis compatibility
                "1Rnd_HE_Grenade_shell",
                "UGL_FlareWhite_F",
                "UGL_FlareGreen_F",
                "UGL_FlareRed_F",
                "UGL_FlareYellow_F",
                "UGL_FlareCIR_F",
                "1Rnd_Smoke_Grenade_shell",
                "1Rnd_SmokeRed_Grenade_shell",
                "1Rnd_SmokeGreen_Grenade_shell",
                "1Rnd_SmokeYellow_Grenade_shell",
                "1Rnd_SmokePurple_Grenade_shell",
                "1Rnd_SmokeBlue_Grenade_shell",
                "1Rnd_SmokeOrange_Grenade_shell",
                "3Rnd_HE_Grenade_shell",
                "3Rnd_UGL_FlareWhite_F",
                "3Rnd_UGL_FlareGreen_F",
                "3Rnd_UGL_FlareRed_F",
                "3Rnd_UGL_FlareYellow_F",
                "3Rnd_UGL_FlareCIR_F",
                "3Rnd_Smoke_Grenade_shell",
                "3Rnd_SmokeRed_Grenade_shell",
                "3Rnd_SmokeGreen_Grenade_shell",
                "3Rnd_SmokeYellow_Grenade_shell",
                "3Rnd_SmokePurple_Grenade_shell",
                "3Rnd_SmokeBlue_Grenade_shell",
                "3Rnd_SmokeOrange_Grenade_shell",

                // ACE3 Compatibility
                "ACE_HuntIR_M203"
            };
        };
        class M320_GL : M203_GL {
            magazines[] = {
                "rhs_mag_M441_HE",
                "rhs_mag_M433_HEDP",
                "rhs_mag_M4009",
                "rhs_mag_m576",
                "rhs_mag_M585_white",
                "rhs_mag_M661_green",
                "rhs_mag_M662_red",
                "rhs_mag_M713_red",
                "rhs_mag_M714_white",
                "rhs_mag_M715_green",
                "rhs_mag_M716_yellow",

                // bis compatibility
                "1Rnd_HE_Grenade_shell",
                "UGL_FlareWhite_F",
                "UGL_FlareGreen_F",
                "UGL_FlareRed_F",
                "UGL_FlareYellow_F",
                "UGL_FlareCIR_F",
                "1Rnd_Smoke_Grenade_shell",
                "1Rnd_SmokeRed_Grenade_shell",
                "1Rnd_SmokeGreen_Grenade_shell",
                "1Rnd_SmokeYellow_Grenade_shell",
                "1Rnd_SmokePurple_Grenade_shell",
                "1Rnd_SmokeBlue_Grenade_shell",
                "1Rnd_SmokeOrange_Grenade_shell",
                "3Rnd_HE_Grenade_shell",
                "3Rnd_UGL_FlareWhite_F",
                "3Rnd_UGL_FlareGreen_F",
                "3Rnd_UGL_FlareRed_F",
                "3Rnd_UGL_FlareYellow_F",
                "3Rnd_UGL_FlareCIR_F",
                "3Rnd_Smoke_Grenade_shell",
                "3Rnd_SmokeRed_Grenade_shell",
                "3Rnd_SmokeGreen_Grenade_shell",
                "3Rnd_SmokeYellow_Grenade_shell",
                "3Rnd_SmokePurple_Grenade_shell",
                "3Rnd_SmokeBlue_Grenade_shell",
                "3Rnd_SmokeOrange_Grenade_shell",

                // ACE3 Compatibility
                "ACE_HuntIR_M203"
            };
        };
    };
    class rhs_weap_m4a1;
    class rhs_weap_hk416d10: rhs_weap_m4a1 {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 254;
    };
    class rhs_weap_hk416d145: rhs_weap_hk416d10 {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 368.3;
    };
    class rhs_weap_m27iar: rhs_weap_m4a1 {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 419.1;
    };
    class rhs_weap_m4a1_blockII;
    class rhs_weap_mk18: rhs_weap_m4a1_blockII {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 261.62;
    };
    class rhs_weap_m16a4: rhs_weap_m4_Base {
        ACE_barrelTwist = 177.8;
        ACE_barrelLength = 508.0;
    };
    class rhs_weap_lmg_minimi_railed; // Rifle_Base_F - scope = private;
    class rhs_weap_m249_pip_S: rhs_weap_lmg_minimi_railed {
        ACE_barrelLength = 348; 
        ACE_barrelTwist = 177.8;
        ACE_Overheating_allowSwapBarrel = 1;
    };
    class rhs_weap_m249_pip_L: rhs_weap_lmg_minimi_railed {
        ACE_barrelLength = 464.8;
        ACE_barrelTwist = 177.8;
        ACE_Overheating_allowSwapBarrel = 1;
    };
    class rhs_weap_m240_base; // Rifle_Long_Base_F
    class rhs_weap_m240B: rhs_weap_m240_base {
        ACE_barrelTwist = 304.8;
        ACE_barrelLength = 629.92;
        ACE_Overheating_allowSwapBarrel = 1;
    };
    class rhs_weap_m14ebrri: srifle_EBR_F {
        ACE_barrelTwist = 304.8;
        ACE_barrelLength = 558.8;
        ACE_Overheating_dispersion = 0.75;
    };
    class rhs_weap_sr25: rhs_weap_m14ebrri {
        ACE_barrelTwist = 285.75;
        ACE_barrelLength = 609.6;
    };
    class rhs_weap_sr25_ec: rhs_weap_sr25 {
        ACE_barrelTwist = 285.75;
        ACE_barrelLength = 508.0;
    };
    class rhs_weap_M590_5RD: Rifle_Base_F {
        ACE_barrelTwist = 0.0;
        ACE_twistDirection = 0;
        ACE_barrelLength = 469.9;
    };
    class rhs_weap_M590_8RD: rhs_weap_M590_5RD {
        ACE_barrelTwist = 0.0;
        ACE_twistDirection = 0;
        ACE_barrelLength = 508.0;
    };
    class SMG_01_F;
    class rhsusf_weap_MP7A1_base_f : SMG_01_F {
        ACE_barrelTwist = 160.0;
        ACE_barrelLength = 180.0;     
    };
    // RHS pistols
    class hgun_ACPC2_F;
    class rhsusf_weap_m1911a1: hgun_ACPC2_F {
        ACE_barrelTwist = 406.4;
        ACE_barrelLength = 127.0;
    };
    class hgun_P07_F;
    class rhsusf_weap_glock17g4: hgun_P07_F {
        ACE_barrelTwist = 248.92;
        ACE_barrelLength = 114.046;
    };
    class rhsusf_weap_m9: rhsusf_weap_glock17g4 {
        ACE_barrelTwist = 248.92;
        ACE_barrelLength = 124.46;
    };
    // RHS sniper scopes
    class ItemCore;
    class InventoryOpticsItem_Base_F;
    class rhsusf_acc_sniper_base: ItemCore {
        ACE_ScopeAdjust_Vertical[] = {-4, 30};
        ACE_ScopeAdjust_Horizontal[] = {-6, 6};
        ACE_ScopeAdjust_VerticalIncrement = 0.1;
        ACE_ScopeAdjust_HorizontalIncrement = 0.1;
        class ItemInfo: InventoryOpticsItem_Base_F {
            class OpticsModes {
                class pso1_scope {
                    discreteDistance[] = {100};
                    discreteDistanceInitIndex = 0;
                };
            };
        };
    };
    class rhsusf_acc_LEUPOLDMK4: rhsusf_acc_sniper_base {};
    class rhsusf_acc_LEUPOLDMK4_2: rhsusf_acc_sniper_base {
        class ItemInfo: InventoryOpticsItem_Base_F {
            class OpticsModes {
                class pso1_scope {
                    discreteDistance[] = {100};
                    discreteDistanceInitIndex = 0;
                };
            };
        };
    };
    class rhsusf_acc_LEUPOLDMK4_2_d : rhsusf_acc_LEUPOLDMK4_2 {};
    class rhsusf_acc_premier: rhsusf_acc_LEUPOLDMK4_2 {
        class ItemInfo: InventoryOpticsItem_Base_F {
            class OpticsModes {
                class pso1_scope {
                    discreteDistance[] = {100};
                    discreteDistanceInitIndex = 0;
                };
            };
        };
    };
    class rhsusf_acc_premier_low : rhsusf_acc_premier {};
    class rhsusf_acc_premier_anpvs27: rhsusf_acc_premier {
        class ItemInfo: InventoryOpticsItem_Base_F {
            class OpticsModes {
                class pso1_nvg {
                    discreteDistance[] = {100};
                    discreteDistanceInitIndex = 0;
                };
            };
        };
    };
    // RHS lauchers
    class rhs_weap_fgm148: launch_O_Titan_F {
        ace_javelin_enabled = 1;
        weaponInfoType = "ACE_RscOptics_javelin";
        modelOptics = "\z\ace\addons\javelin\data\reticle_titan.p3d";
        canLock = 0;
        lockingTargetSound[] = {"",0,1};
        lockedTargetSound[] = {"",0,1};
    };

    class rhsusf_ach_helmet_ocp;
    class rhsusf_opscore_01: rhsusf_ach_helmet_ocp {
        ace_hearing_protection = 0.50;
        ace_hearing_lowerVolume = 0.60;
    };
    class rhsusf_opscore_01_tan: rhsusf_opscore_01 {};
    class rhsusf_opscore_03_ocp: rhsusf_opscore_01 {};

    class rhsusf_cvc_helmet: rhsusf_opscore_01 {
        ace_hearing_protection = 1;
        ace_hearing_lowerVolume = 0.80;
    };
    class rhsusf_cvc_green_helmet: rhsusf_cvc_helmet {};
    class rhsusf_cvc_ess: rhsusf_cvc_helmet {};
    class rhsusf_cvc_green_ess: rhsusf_cvc_ess {};

    class H_PilotHelmetHeli_B;
    class H_CrewHelmetHeli_B;
    class rhsusf_hgu56p: H_PilotHelmetHeli_B {
        ace_hearing_protection = 0.85;
        ace_hearing_lowerVolume = 0.75;
    };
    class rhsusf_hgu56p_mask: H_CrewHelmetHeli_B {
        ace_hearing_protection = 0.85;
        ace_hearing_lowerVolume = 0.75;
    };

    class H_HelmetB;
    class RHS_jetpilot_usaf: H_HelmetB {
        ace_hearing_protection = 1;
        ace_hearing_lowerVolume = 0.80;
    };
};
