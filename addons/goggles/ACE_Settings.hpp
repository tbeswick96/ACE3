
class ACE_Settings {
    class GVAR(effects) {
        category = CSTRING(DisplayName);
        displayName = CSTRING(effects_displayName);
        typeName = "SCALAR";
        value = 2;
        isClientSettable = 1;
        values[] = {ECSTRING(common,Disabled), CSTRING(effects_tintOnly), CSTRING(enabled_tintAndEffects), CSTRING(effects_effectsOnly)};
    };
    class GVAR(showInThirdPerson) {
        category = CSTRING(DisplayName);
        value = 0;
        typeName = "BOOL";
        isClientSettable = 1;
        displayName = CSTRING(ShowInThirdPerson);
    };
};
