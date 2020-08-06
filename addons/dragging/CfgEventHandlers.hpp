
class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};

class Extended_Init_EventHandlers {
    class CAManBase {
        class ADDON {
            init = QUOTE(_this call DFUNC(initPerson));
            exclude[] = {"VirtualMan_F"};
        };
    };
    class StaticWeapon {
        class ADDON {
            init = QUOTE(_this call DFUNC(initObject));
        };
    };
    class ThingX {
        class ADDON {
            init = QUOTE(_this call DFUNC(initObject));
        };
    };
    class Land_PortableLight_single_F {
        class ADDON {
            init = QUOTE(_this call DFUNC(initObject));
        };
    };
    class Land_Camping_Light_F {
        class ADDON {
            init = QUOTE(_this call DFUNC(initObject));
        };
    };
};

class Extended_Killed_EventHandlers {
    class CAManBase {
        class ADDON {
            killed = QUOTE(_this call DFUNC(handleKilled));
        };
    };
};
