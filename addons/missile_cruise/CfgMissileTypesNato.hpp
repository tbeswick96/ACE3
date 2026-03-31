class EGVAR(missileguidance,type_CruiseMissile) {
    enabled = 0;

    pitchRate = 25;
    yawRate = 25;

    canVanillaLock = 0;

    defaultSeekerType = "GPS";
    seekerTypes[] = { "GPS" };

    defaultSeekerLockMode = "LOBL";
    seekerLockModes[] = { "LOBL" };

    defaultNavigationType = "Direct";
    navigationTypes[] = { "Direct" };

    defaultAttackProfile = "cruise_missile";
    attackProfiles[] = { "cruise_missile" };
};
