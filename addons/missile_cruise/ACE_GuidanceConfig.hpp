class EGVAR(missileguidance,AttackProfiles) {
    class cruise_missile {
        name = "";
        visualName = "";
        description = "";

        functionName = QFUNC(attackProfile);
        onFired = QFUNC(onFired);
    };
};
