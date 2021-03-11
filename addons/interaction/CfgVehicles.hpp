
class CBA_Extended_EventHandlers;

class CfgVehicles {
    class ACE_Module;
    class ACE_ModuleInteraction: ACE_Module {
        author = ECSTRING(common,ACETeam);
        category = "ACE";
        displayName = CSTRING(Module_DisplayName);
        function = QFUNC(moduleInteraction);
        scope = 1;
        isGlobal = 1;
        isSingular = 1;
        icon = QPATHTOF(UI\Icon_Module_Interaction_ca.paa);
        class Arguments {
            class EnableTeamManagement {
                displayName = CSTRING(EnableTeamManagement_DisplayName);
                description = CSTRING(EnableTeamManagement_Description);
                typeName = "BOOL";
                defaultValue = 1;
            };
            class DisableNegativeRating {
                displayName = CSTRING(DisableNegativeRating_DisplayName);
                description = CSTRING(DisableNegativeRating_Description);
                typeName = "BOOL";
                defaultValue = 0;
            };
        };
        class ModuleDescription {
            description = CSTRING(Module_Description);
        };
    };

    class Man;
    class CAManBase: Man {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                distance = 4;
                condition = QUOTE(true);
                statement = "";
                icon = "\a3\ui_f\data\IGUI\Cfg\Actions\eject_ca.paa";
                selection = "pelvis";

                class ACE_PassMagazine {
                    displayName = CSTRING(PassMagazine);
                    condition = "";
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                    icon = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargomag_ca.paa";

                    class ACE_PassMagazinePrimary {
                        displayName = CSTRING(PassMagazinePrimary);
                        condition = QUOTE([ARR_3(_player,_target,primaryWeapon _target)] call FUNC(canPassMagazine));
                        statement = QUOTE([ARR_3(_player,_target,primaryWeapon _target)] call FUNC(passMagazine));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 0;
                        icon = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\primaryweapon_ca.paa";
                    };
                    class ACE_PassMagazineHandgun {
                        displayName = CSTRING(PassMagazineHandgun);
                        condition = QUOTE([ARR_3(_player,_target,handgunWeapon _target)] call FUNC(canPassMagazine));
                        statement = QUOTE([ARR_3(_player,_target,handgunWeapon _target)] call FUNC(passMagazine));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 0;
                        icon = "\a3\ui_f\data\gui\Rsc\RscDisplayArsenal\handgun_ca.paa";
                    };
                };

                class ACE_TeamManagement {
                    displayName = CSTRING(TeamManagement);
                    condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam) && {GVAR(EnableTeamManagement)});
                    statement = "";
                    modifierFunction = QUOTE([ARR_3(assignedTeam _target, 'PATHTOF(UI\team\team_management_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;

                    class ACE_AssignTeamRed {
                        displayName = CSTRING(AssignTeamRed);
                        condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam));
                        statement = QUOTE([ARR_3(_target,'RED',true)] call DFUNC(joinTeam));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 1;
                        modifierFunction = QUOTE([ARR_3('RED', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    };
                    class ACE_AssignTeamGreen {
                        displayName = CSTRING(AssignTeamGreen);
                        condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam));
                        statement = QUOTE([ARR_3(_target,'GREEN',true)] call DFUNC(joinTeam));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 1;
                        modifierFunction = QUOTE([ARR_3('GREEN', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    };
                    class ACE_AssignTeamBlue {
                        displayName = CSTRING(AssignTeamBlue);
                        condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam));
                        statement = QUOTE([ARR_3(_target,'BLUE',true)] call DFUNC(joinTeam));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 1;
                        modifierFunction = QUOTE([ARR_3('BLUE', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    };
                    class ACE_AssignTeamYellow {
                        displayName = CSTRING(AssignTeamYellow);
                        condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam));
                        statement = QUOTE([ARR_3(_target,'YELLOW',true)] call DFUNC(joinTeam));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 1;
                        modifierFunction = QUOTE([ARR_3('YELLOW', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    };
                    class ACE_UnassignTeam {
                        displayName = CSTRING(LeaveTeam);
                        condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canJoinTeam) && {assignedTeam _target != 'MAIN'});
                        statement = QUOTE([ARR_3(_target,'MAIN',true)] call DFUNC(joinTeam));
                        exceptions[] = {"isNotSwimming"};
                        showDisabled = 1;
                        modifierFunction = QUOTE([ARR_3('MAIN', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                    };
                };

                class ACE_JoinGroup {
                    displayName = CSTRING(JoinGroup);
                    condition = QUOTE(GVAR(EnableTeamManagement) && {[ARR_2(_player,_target)] call DFUNC(canJoinGroup)});
                    statement = QUOTE([_player] joinSilent group _target);
                    modifierFunction = QUOTE(call FUNC(modifyJoinGroupAction));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                    icon = QPATHTOF(UI\team\team_management_ca.paa);
                };
                class ACE_GetDown {
                    displayName = CSTRING(GetDown);
                    condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canInteractWithCivilian));
                    statement = QUOTE([ARR_2(_player,_target)] call DFUNC(getDown));
                    showDisabled = 0;
                };
                class ACE_SendAway {
                    displayName = CSTRING(SendAway);
                    condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canInteractWithCivilian));
                    statement = QUOTE([ARR_2(_player,_target)] call DFUNC(sendAway));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                };
                class ACE_Pardon {
                    displayName = CSTRING(Pardon);
                    condition = QUOTE([ARR_2(_player,_target)] call DFUNC(canPardon));
                    statement = QUOTE([ARR_2(_player,_target)] call DFUNC(pardon));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                };
                class ACE_GetOut {
                    displayName = CSTRING(GetOut);
                    condition = QUOTE(!(isNull objectParent _target) && [ARR_2(_player,_target)] call DFUNC(canInteractWithCivilian));
                    statement = QUOTE([_target] call EFUNC(common,unloadPerson));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                };

                class GVAR(PullOutBody) {
                    displayName = CSTRING(PullOutBody);
                    condition = QUOTE(call DFUNC(canPullOutBody));
                    statement = QUOTE(call DFUNC(pullOutBody));
                    exceptions[] = {"isNotSwimming"};
                    icon = "\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\getout_ca.paa";
                };
            };

            class ACE_Torso {
                displayName = CSTRING(Torso);
                selection = "spine3";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_Head {
                displayName = CSTRING(Head);
                selection = "pilot";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_ArmLeft {
                displayName = CSTRING(ArmLeft);
                selection = "LeftForeArm";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_ArmRight {
                displayName = CSTRING(ArmRight);
                selection = "RightForeArm";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_LegLeft {
                displayName = CSTRING(LegLeft);
                selection = "LKnee";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_LegRight {
                displayName = CSTRING(LegRight);
                selection = "RKnee";
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_Weapon {
                displayName = CSTRING(Weapon);
                position = QUOTE(call DFUNC(getWeaponPos));
                distance = 1.50;
                condition = "";
                statement = "";
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_TapShoulderRight {
                displayName = CSTRING(TapShoulder);
                selection = "rightshoulder";
                distance = 2.0;
                condition = QUOTE([ARR_2(_player, _target)] call DFUNC(canTapShoulder));
                statement = QUOTE([ARR_3(_player, _target, 0)] call DFUNC(tapShoulder));
                exceptions[] = {"isNotSwimming"};
            };
            class ACE_TapShoulderLeft {
                displayName = CSTRING(TapShoulder);
                selection = "leftshoulder";
                distance = 2.0;
                condition = QUOTE([ARR_2(_player, _target)] call DFUNC(canTapShoulder));
                statement = QUOTE([ARR_3(_player, _target, 1)] call DFUNC(tapShoulder));
                exceptions[] = {"isNotSwimming"};
            };
        };

        class ACE_SelfActions {
            class ACE_TeamManagement {
                displayName = CSTRING(TeamManagement);
                condition = QUOTE(GVAR(EnableTeamManagement));
                exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                statement = "";
                modifierFunction = QUOTE([ARR_3(assignedTeam _target, 'PATHTOF(UI\team\team_management_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                showDisabled = 1;

                class ACE_JoinTeamRed {
                    displayName = CSTRING(JoinTeamRed);
                    condition = QUOTE(true);
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE([ARR_3(_player,'RED',true)] call DFUNC(joinTeam));
                    showDisabled = 1;
                    modifierFunction = QUOTE([ARR_3('RED', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                };
                class ACE_JoinTeamGreen {
                    displayName = CSTRING(JoinTeamGreen);
                    condition = QUOTE(true);
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE([ARR_3(_player,'GREEN',true)] call DFUNC(joinTeam));
                    showDisabled = 1;
                    modifierFunction = QUOTE([ARR_3('GREEN', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                };
                class ACE_JoinTeamBlue {
                    displayName = CSTRING(JoinTeamBlue);
                    condition = QUOTE(true);
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE([ARR_3(_player,'BLUE',true)] call DFUNC(joinTeam));
                    showDisabled = 1;
                    modifierFunction = QUOTE([ARR_3('BLUE', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                };
                class ACE_JoinTeamYellow {
                    displayName = CSTRING(JoinTeamYellow);
                    condition = QUOTE(true);
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE([ARR_3(_player,'YELLOW',true)] call DFUNC(joinTeam));
                    showDisabled = 1;
                    modifierFunction = QUOTE([ARR_3('YELLOW', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                };
                class ACE_LeaveTeam {
                    displayName = CSTRING(LeaveTeam);
                    condition = QUOTE(assignedTeam _player != 'MAIN');
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE([ARR_3(_player,'MAIN',true)] call DFUNC(joinTeam));
                    showDisabled = 1;
                    modifierFunction = QUOTE([ARR_3('MAIN', 'PATHTOF(UI\team\team_white_ca.paa)', _this select 3)] call FUNC(modifyTeamManagementAction));
                };
                class ACE_BecomeLeader {
                    displayName = CSTRING(BecomeLeader);
                    condition = QUOTE(_this call DFUNC(canBecomeLeader));
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE(_this call DFUNC(doBecomeLeader));
                    showDisabled = 1;
                    icon = QPATHTOF(UI\team\team_white_ca.paa);
                };
                class ACE_LeaveGroup {
                    displayName = CSTRING(LeaveGroup);
                    condition = QUOTE(count (units group _player) > 1);
                    exceptions[] = {"isNotSwimming", "isNotInside", "isNotSitting", "isNotOnLadder", "isNotRefueling"};
                    statement = QUOTE(_oldGroup = units group _player; _newGroup = createGroup side group _player; [_player] joinSilent _newGroup; {_player reveal _x} forEach _oldGroup;);
                    showDisabled = 1;
                    icon = QPATHTOF(UI\team\team_management_ca.paa);
                };
            };

            class ACE_Equipment {
                displayName = CSTRING(Equipment);
                condition = QUOTE(true);
                exceptions[] = {"isNotSwimming", "isNotInside", "notOnMap", "isNotSitting"};
                statement = "";
                showDisabled = 1;
                icon = "";  // @todo

                class GVAR(weaponAttachments) {
                    displayName = "$STR_A3_CfgEditorSubcategories_EdSubcat_SideSlot0";
                    condition = QGVAR(enableWeaponAttachments);
                    exceptions[] = {"isNotInside", "isNotSwimming", "isNotSitting"};
                    insertChildren = QUOTE(call DFUNC(getWeaponAttachmentsActions));
                    modifierFunction = QUOTE(_this select 3 set [ARR_2(2, getText (configFile >> 'CfgWeapons' >> currentWeapon (_this select 0) >> 'picture'))];);
                };
            };
        };
    };

    class LandVehicle;
    class Car: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                position = QUOTE(call DFUNC(getVehiclePos));
                selection = "";
                distance = 4;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
            class GVAR(smashWindshield) {
                displayName = CSTRING(SmashWindshield);
                condition = QUOTE(_player == driver _target && {private _damage = _target getHitPointDamage 'HitGlass1'; _damage > 0.5 && {_damage < 1}});
                statement = QUOTE(playSound3D [ARR_2('A3\Sounds_F\weapons\hits\glass_2.wss',_target)]; _target setHitPointDamage [ARR_2('HitGlass1',1)];);
            };
        };
    };

    class Car_F: Car{};
    class Quadbike_01_base_F: Car_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                class GVAR(flip) {
                    displayName = CSTRING(Flip);
                    condition = QUOTE(call DFUNC(canFlip));
                    statement = QUOTE([ARR_3(QQGVAR(flip),_target,_target)] call CBA_fnc_targetEvent);
                };
                class GVAR(push) {
                    displayName = CSTRING(Push);
                    condition = QUOTE(_target call FUNC(canPush));
                    statement = QUOTE(call FUNC(push));
                };
            };
        };
    };
    class Kart_01_Base_F: Car_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                class GVAR(flip) {
                    displayName = CSTRING(Flip);
                    condition = QUOTE(call DFUNC(canFlip));
                    statement = QUOTE([ARR_3(QQGVAR(flip),_target,_target)] call CBA_fnc_targetEvent);
                };
                class GVAR(push) {
                    displayName = CSTRING(Push);
                    condition = QUOTE(_target call FUNC(canPush));
                    statement = QUOTE(call FUNC(push));
                };
            };
        };
    };

    class Tank: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                position = QUOTE(call DFUNC(getVehiclePos));
                selection = "";
                distance = 4;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class Motorcycle: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                selection = "";
                distance = 10;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                exceptions[] = {"isNotSwimming"};
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class Air;
    class Helicopter: Air {
        GVAR(bodyWidth) = 3;
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                position = QUOTE([ARR_2(_target, EGVAR(interact_menu,cameraPosASL))] call DFUNC(getVehiclePosComplex));
                selection = "";
                distance = 4;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class Plane: Air {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                position = QUOTE([ARR_2(_target, EGVAR(interact_menu,cameraPosASL))] call DFUNC(getVehiclePosComplex));
                selection = "";
                distance = 4;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class VTOL_Base_F;
    class VTOL_01_base_F: VTOL_Base_F {
        GVAR(bodyWidth) = 4;
        GVAR(bodyLength) = 10;
    };
    class VTOL_02_base_F: VTOL_Base_F {
        GVAR(bodyWidth) = 3;
        GVAR(bodyLength) = 7;
    };

    class Ship;
    class Ship_F: Ship {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                position = QUOTE(call DFUNC(getVehiclePos));
                selection = "";
                distance = 4;
                condition = "true";

                class ACE_Push {
                    displayName = CSTRING(Push);
                    distance = 6;
                    condition = QUOTE(_target call FUNC(canPush));
                    statement = QUOTE(_this call FUNC(push));
                    exceptions[] = {"isNotSwimming"};
                    showDisabled = 0;
                };
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class Boat_F;
    class Boat_Transport_02_base_F: Boat_F {
        GVAR(canPush) = 1;
    };

    class StaticWeapon: LandVehicle {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                selection = "gunnerview";
                distance = 4;
                condition = "true";
                class ACE_Passengers {
                    displayName = CSTRING(Passengers);
                    condition = QUOTE(alive _target);
                    statement = "";
                    exceptions[] = {"isNotSwimming"};
                    insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
                };
                class GVAR(flip) {
                    displayName = CSTRING(Flip);
                    condition = QUOTE(call DFUNC(canFlip));
                    statement = QUOTE([ARR_3(QQGVAR(flip),_target,_target)] call CBA_fnc_targetEvent);
                };
            };
        };

        class ACE_SelfActions {
            class ACE_Passengers {
                displayName = CSTRING(Passengers);
                condition = QUOTE(alive _target);
                statement = "";
                insertChildren = QUOTE(_this call DFUNC(addPassengersActions));
            };
        };
    };

    class StaticMGWeapon: StaticWeapon {};
    class HMG_01_base_F: StaticMGWeapon {};

    class HMG_01_high_base_F: HMG_01_base_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                position = "[-0.172852,0.164063,-0.476091]";
            };
        };
    };

    class AA_01_base_F: StaticMGWeapon {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                position = "[0,0.515869,-0.200671]";
            };
        };
    };

    class AT_01_base_F: StaticMGWeapon {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                position = "[0,0.515869,-0.200671]";
            };
        };
    };

    class ThingX;
    class ReammoBox_F: ThingX {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                selection = "";
                distance = 2;
                condition = "true";
                class ACE_OpenBox {
                    displayName = CSTRING(OpenBox);
                    condition = QUOTE((alive _target) && {(getNumber (configOf _target >> 'disableInventory')) == 0});
                    statement = QUOTE(_player action [ARR_2(QUOTE(QUOTE(Gear)), _target)]);
                    showDisabled = 0;
                };
            };
        };
        class ACE_SelfActions {};
    };
    class Slingload_base_F: ReammoBox_F {};
    class Slingload_01_Base_F: Slingload_base_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                distance = 5;
            };
        };
    };
    class Pod_Heli_Transport_04_base_F: Slingload_base_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                distance = 5;
            };
        };
    };

    class ACE_RepairItem_Base: ThingX {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                selection = "";
                distance = 2;
                condition = "true";
            };
        };

        class ACE_SelfActions {};
    };

    class Lamps_base_F;
    class Land_PortableLight_single_F: Lamps_base_F {
        class EventHandlers {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers {};
        };
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                distance = 2;

                class GVAR(TurnOn) {
                    displayName = CSTRING(TurnOn);
                    icon = "\A3\Ui_f\data\IGUI\Cfg\VehicleToggles\LightsIconOn_ca.paa";
                    condition = QUOTE(alive _target && !(_target getVariable [ARR_2(QQGVAR(isLightOn),true)]));
                    statement = QUOTE([ARR_3(QQGVAR(setLight),[ARR_2(_target,true)],_target)] call CBA_fnc_targetEvent);
                };
                class GVAR(TurnOff) {
                    displayName = CSTRING(TurnOff);
                    icon = "\A3\ui_f\data\igui\cfg\actions\ico_cpt_land_OFF_ca.paa";
                    condition = QUOTE(alive _target && _target getVariable [ARR_2(QQGVAR(isLightOn),true)]);
                    statement = QUOTE([ARR_3(QQGVAR(setLight),[ARR_2(_target,false)],_target)] call CBA_fnc_targetEvent);
                };
            };
        };
    };

    class FloatingStructure_F;
    class Land_Camping_Light_F: FloatingStructure_F {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                distance = 2;

                class GVAR(TurnOn) {
                    displayName = CSTRING(TurnOn);
                    icon = "\A3\Ui_f\data\IGUI\Cfg\VehicleToggles\LightsIconOn_ca.paa";
                    condition = QUOTE(alive _target && !isCollisionLightOn _target);
                    statement = QUOTE([ARR_3(QQGVAR(setCollisionLight),[ARR_2(_target,true)],_target)] call CBA_fnc_targetEvent);
                };
                class GVAR(TurnOff) {
                    displayName = CSTRING(TurnOff);
                    icon = "\A3\ui_f\data\igui\cfg\actions\ico_cpt_land_OFF_ca.paa";
                    condition = QUOTE(alive _target && isCollisionLightOn _target);
                    statement = QUOTE([ARR_3(QQGVAR(setCollisionLight),[ARR_2(_target,false)],_target)] call CBA_fnc_targetEvent);
                };
            };
        };
    };

    class Land_Camping_Light_off_F: ThingX {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                distance = 2;

                // to make "Camping Lantern (Off)" be turned on we replace it with "Camping Lantern"
                class GVAR(TurnOn) {
                    displayName = CSTRING(TurnOn);
                    icon = "\A3\Ui_f\data\IGUI\Cfg\VehicleToggles\LightsIconOn_ca.paa";
                    condition = QUOTE(alive _target);
                    statement = QUOTE(\
                        private _position = getPosATL _target;\
                        private _vectorDirAndUp = [ARR_2(vectorDir _target,vectorUp _target)];\
                        deleteVehicle _target;\
                        private _newLamp = 'Land_Camping_Light_F' createVehicle [ARR_3(0,0,0)];\
                        _newLamp setPosATL _position;\
                        _newLamp setVectorDirAndUp _vectorDirAndUp;\
                    );
                };
            };
        };
    };

    class RoadCone_F: ThingX {
        class ACE_Actions {
            class ACE_MainActions {
                displayName = CSTRING(MainAction);
                selection = "";
                distance = 2;
                condition = "true";
            };
        };
    };

    class RoadBarrier_F: RoadCone_F {
        class ACE_Actions: ACE_Actions {
            class ACE_MainActions: ACE_MainActions {
                position = "[0,0,0.500671]";
            };
        };
    };
};
