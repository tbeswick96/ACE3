class CfgAmmo {
    class Default;
    class BulletBase;
    class R3F_9x19_Ball: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L360
        typicalSpeed = 350; // R3F config
        airFriction = -0.00201185; // ACE3 value, default -0.001413
        ACE_caliber = 9.017;
        ACE_bulletLength = 15.494;
        ACE_bulletMass = 8.0352;
        ACE_ammoTempMuzzleVelocityShifts[] = {-2.655, -2.547, -2.285, -2.012, -1.698, -1.280, -0.764, -0.153, 0.596, 1.517, 2.619};
        ACE_ballisticCoefficients[] = {0.165};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {340, 370, 400};
        ACE_barrelLengths[] = {101.6, 127.0, 228.6};
    };
    class R3F_556x45_Ball: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L9
        typicalSpeed = 930; // R3F config
        airFriction = -0.00130094; // ACE3 value, default -0.001625
        ACE_caliber = 5.69;
        ACE_bulletLength = 23.012;
        ACE_bulletMass = 4.0176;
        ACE_ammoTempMuzzleVelocityShifts[] = {-27.20, -26.44, -23.76, -21.00, -17.54, -13.10, -7.95, -1.62, 6.24, 15.48, 27.75};
        ACE_ballisticCoefficients[] = {0.151};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 7;
        ACE_muzzleVelocities[] = {723, 764, 796, 825, 843, 866, 878, 892, 906, 915, 922, 900};
        ACE_barrelLengths[] = {210.82, 238.76, 269.24, 299.72, 330.2, 360.68, 391.16, 419.1, 449.58, 480.06, 508.0, 609.6};
    };
    class R3F_762x51_Ball: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L152
        typicalSpeed = 820; // R3F config
        airFriction = -0.00103711; // ACE3 value, default -0.00095
        ACE_caliber = 7.823;
        ACE_bulletLength = 28.956;
        ACE_bulletMass = 9.4608;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.2};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ICAO";
        ACE_dragModel = 7;
        ACE_muzzleVelocities[] = {700, 800, 820, 833, 845};
        ACE_barrelLengths[] = {254.0, 406.4, 508.0, 609.6, 660.4};
    };
    class R3F_762x51_Ball2: R3F_762x51_Ball { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L152
        typicalSpeed = 850; // R3F config
        airFriction = -0.00103711; // ACE3 value, default -0.00095
        ACE_caliber = 7.823;
        ACE_bulletLength = 28.956;
        ACE_bulletMass = 9.4608;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.2};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ICAO";
        ACE_dragModel = 7;
        ACE_muzzleVelocities[] = {850};
        ACE_barrelLengths[] = {650};
    };
    class R3F_762x51_Minimi_Ball: R3F_762x51_Ball { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L152
        airFriction = -0.00103711; // ACE3 value, default -0.002000
    };
    class R3F_127x99_Ball: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L494
        typicalSpeed = 780; // R3F config
        airFriction = -0.00058679; // ACE3 value, default -0.00086
        ACE_caliber = 12.954;
        ACE_bulletLength = 58.674;
        ACE_bulletMass = 41.9256;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.670};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {780};
        ACE_barrelLengths[] = {700};
    };
    class R3F_127x99_PEI: R3F_127x99_Ball { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L494
        typicalSpeed = 780; // R3F config
        airFriction = -0.00058679; // ACE3 value, default -0.00086
        ACE_caliber = 12.954;
        ACE_bulletLength = 58.674;
        ACE_bulletMass = 41.9256;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.670};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {780};
        ACE_barrelLengths[] = {700};
    };
    class R3F_127x99_Ball2: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L494
        typicalSpeed = 850; // R3F config
        airFriction = -0.00058679; // ACE3 value, default -0.00086
        ACE_caliber = 12.954;
        ACE_bulletLength = 58.674;
        ACE_bulletMass = 41.9256;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.670};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {850};
        ACE_barrelLengths[] = {736.6};
    };
    class R3F_127x99_PEI2: R3F_127x99_Ball2 { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L494
        typicalSpeed = 850; // R3F config
        airFriction = -0.00058679; // ACE3 value, default -0.00086
        ACE_caliber = 12.954;
        ACE_bulletLength = 58.674;
        ACE_bulletMass = 41.9256;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.670};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {850};
        ACE_barrelLengths[] = {736.6};
    };
    class R3F_127x99_Ball3: BulletBase { // https://github.com/acemod/ACE3/blob/master/addons/ballistics/CfgAmmo.hpp#L494
        typicalSpeed = 820; // R3F config
        airFriction = -0.00058679; // ACE3 value, default -0.00086
        ACE_caliber = 12.954;
        ACE_bulletLength = 58.674;
        ACE_bulletMass = 41.9256;
        ACE_ammoTempMuzzleVelocityShifts[] = {-26.55, -25.47, -22.85, -20.12, -16.98, -12.80, -7.64, -1.53, 5.96, 15.17, 26.19};
        ACE_ballisticCoefficients[] = {0.670};
        ACE_velocityBoundaries[] = {};
        ACE_standardAtmosphere = "ASM";
        ACE_dragModel = 1;
        ACE_muzzleVelocities[] = {820};
        ACE_barrelLengths[] = {736.6};
    };
};
