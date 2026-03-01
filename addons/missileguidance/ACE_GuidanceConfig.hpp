class GVAR(AttackProfiles) {
    class LIN {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_LIN);
    };
    // empty classes for backwards compat
    class MID: LIN {
    };
    class HI: LIN {
    };
    class DIR {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_DIR);
    };
    class LOFT {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_LOFT);
    };
    class JAV_DIR {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_JAV_DIR);
    };
    class JAV_TOP {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_JAV_TOP);
    };
    class WIRE {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_WIRE);
        onFired = QFUNC(wire_onFired);
    };
    class BEAM {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_BEAM);
        onFired = QFUNC(wire_onFired); // since Beam guidance is pretty much the same as Wire guidance, we can reuse this
    };
    class JDAM {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_JDAM);
        onFired = QFUNC(gps_attackOnFired);
    };
    class cruise_missile {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile_cruise_missile);
        onFired = QFUNC(cruise_missile_onFired);
    };
};

class GVAR(SeekerTypes) {
    class SALH {
        name = "SALH";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_SALH);
    };
    class Optic {
        name = "Optic";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_Optic);
    };
    class SACLOS {
        name = "SACLOS";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_SACLOS);
        onFired = QFUNC(SACLOS_onFired);
    };
    class MCLOS {
        name = "MCLOS";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_MCLOS);
        onFired = QFUNC(MCLOS_onFired);
    };
    class MillimeterWaveRadar {
        name = "MMW Radar";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_MWR);
        onFired = QFUNC(mwr_onFired);
    };
    class GPS {
        name = "GPS";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_GPS);
        onFired = QFUNC(gps_seekerOnFired);
    };
    class IR {
        name = "IR";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_IR);
        onFired = QFUNC(IR_onFired);
    };
    class DopplerRadar {
        name = "Doppler Radar";
        visualName = "";
        description = "";

        functionName = QFUNC(seekerType_Doppler);
        onFired = QFUNC(doppler_onFired);
    };
};

class GVAR(NavigationTypes) {
    class Direct {
        functionName = QFUNC(navigationType_direct);
        onFired = "";
    };
    class Line {
        functionName = QFUNC(navigationType_line);
        onFired = QFUNC(line_onFired);
    };
    class LineOfSight {
        functionName = QFUNC(navigationType_lineOfSight);
        onFired = QFUNC(proNav_onFired);
    };
    class ProportionalNavigation {
        functionName = QFUNC(navigationType_proNav);
        onFired = QFUNC(proNav_onFired);
    };
    class AugmentedProportionalNavigation {
        functionName = QFUNC(navigationType_augmentedProNav);
        onFired = QFUNC(proNav_onFired);
    };
    class ZeroEffortMiss {
        functionName = QFUNC(navigationType_zeroEffortMiss);
        onFired = QFUNC(proNav_onFired);
    };
};
