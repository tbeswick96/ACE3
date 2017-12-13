#define CAMOUFLAGE_DELETE

#define TRENCH_INIT class GVAR(trenchInit) { \
        init = QUOTE(_this call FUNC(initTrench)); \
    }

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

class Extended_Killed_EventHandlers {
    class CAManBase {
        class ADDON {
            killed = QUOTE(_this call FUNC(handleKilled));
        };
    };
};

class Extended_DisplayLoad_EventHandlers {
    class RscDisplayMission {
        ADDON = QUOTE(_this call COMPILE_FILE(XEH_missionDisplayLoad));
    };
};

class Extended_Deleted_EventHandlers {
    class ACE_envelope_small {
        class GVAR(camouflageDelete) {
            deleted = QUOTE(if (isServer) then {_this call FUNC(deleteCamouflage)});
        };
    };
    class ACE_envelope_big: ACE_envelope_small {};
    class ACE_envelope_gigant: ACE_envelope_small {};
    class ACE_envelope_vehicle: ACE_envelope_small {};
};

class Extended_Init_EventHandlers {
    class ACE_envelope_small {
        class GVAR(trenchInit) {
            init = QUOTE(_this call FUNC(initTrench));
        };
    };

    class ACE_envelope_big: ACE_envelope_small {};
    class ACE_envelope_gigant: ACE_envelope_small {};
    class ACE_envelope_vehicle: ACE_envelope_small {};
};
