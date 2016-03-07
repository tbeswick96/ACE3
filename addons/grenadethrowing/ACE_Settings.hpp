class ACE_Settings {
    class GVAR(Enabled) {
        category = CSTRING(Category);
        displayName = CSTRING(EnableThrowingSystem_DisplayName);
        description = CSTRING(EnableThrowingSystem_Description);
        typeName = "BOOL";
        value = 1;
        isClientSettable = 1;
    };
    class GVAR(ShowThrowArc) {
        category = CSTRING(Category);
        displayName = CSTRING(ShowThrowArc_DisplayName);
        description = CSTRING(ShowThrowArc_Description);
        typeName = "BOOL";
        value = 1;
        isClientSettable = 1;
    };
    class GVAR(ShowMouseControls) {
        category = CSTRING(Category);
        displayName = CSTRING(ShowMouseControls_DisplayName);
        description = CSTRING(ShowMouseControls_Description);
        typeName = "BOOL";
        value = 1;
        isClientSettable = 1;
    };
};
