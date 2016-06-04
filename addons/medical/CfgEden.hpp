class ctrlToolbox;

class Cfg3DEN {
    class Attributes {
        class Default;
        class Title: Default {
            class Controls {
                class Title;
            };
        };
        class GVAR(isMedicControl): Title {
            attributeLoad = "(_this controlsGroupCtrl 100) lbsetcursel (((_value + 1) min 3) max 0);";
            attributeSave = "(missionnamespace getvariable ['ace_isMeidc_temp',0]) - 1;";
            class Controls: Controls {
                class Title: Title{};
                class Value: ctrlToolbox {
                    idc = 100;
                    style = "0x02";
                    x = "48 * (pixelW * pixelGrid * 0.25)";
                    w = "82 * (pixelW * pixelGrid * 0.25)";
                    h = "5 * (pixelH * pixelGrid * 0.25)";
                    rows = 1;
                    columns = 4;
                    strings[] = {"$STR_3DEN_Attributes_Lock_Default_text", CSTRING(AssignMedicRoles_role_none), CSTRING(AssignMedicRoles_role_medic), CSTRING(AssignMedicRoles_role_doctorShort)};
                    onToolboxSelChanged = "missionnamespace setvariable ['ace_isMeidc_temp',_this select 1];";
                };
            };
        };
    };
    class Object {
        class AttributeCategories {
            class ace_attributes {
                class Attributes {
                    class ace_isMedic {
                        property = QUOTE(ace_isMedic);
                        control = QGVAR(isMedicControl);
                        displayName = CSTRING(AssignMedicRoles_role_DisplayName);
                        tooltip = CSTRING(Attributes_isMedic_Description);
                        expression = QUOTE(if (_value != -1) then {_this setVariable [ARR_3(QUOTE(QGVAR(medicClass)),_value, true)];};);
                        typeName = "NUMBER";
                        condition = "objectBrain";
                        defaultValue = "-1";
                    };
                    class ace_isMedicalVehicle {
                        property = QUOTE(ace_isMedicalVehicle);
                        value = 0;
                        control = "CheckboxNumber";
                        displayName = CSTRING(AssignMedicVehicle_enabled_DisplayName);
                        tooltip = CSTRING(Attributes_isMedicalVehicle_Description);
                        expression = QUOTE(_this setVariable [ARR_3(QUOTE(QGVAR(medicClass)),_value, true)];);
                        typeName = "NUMBER";
                        condition = "objectVehicle";
                        defaultValue = 0;
                    };
                    class ace_isMedicalFacility {
                        property = QUOTE(ace_isMedicalFacility);
                        value = 0;
                        control = "Checkbox";
                        displayName = CSTRING(AssignMedicalFacility_enabled_DisplayName);
                        tooltip = CSTRING(AssignMedicalFacility_enabled_Description);
                        expression = QUOTE(_this setVariable [ARR_3(QUOTE(QGVAR(isMedicalFacility)),_value, true)];);
                        typeName = "BOOL";
                        condition = "(1 - objectBrain) * (1 - objectVehicle)";
                        defaultValue = "false";
                    };
                };
            };
        };
    };
};
