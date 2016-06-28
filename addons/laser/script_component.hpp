#define COMPONENT laser
#define COMPONENT_BEAUTIFIED Laser
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define CBA_DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_LASER
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_LASER
    #define DEBUG_SETTINGS DEBUG_SETTINGS_LASER
#endif

#include "\z\ace\addons\main\script_macros.hpp"


#define FIREMODE_DIRECT_LOAL 1


#define __LaserDesignatorIGUI (uiNamespace getVariable ["ACE_RscOptics_LaserDesignator", nil])
#define __LaserDesignatorIGUI_LaserCode (__LaserDesignatorIGUI displayCtrl 123001)
#define __LaserDesignatorIGUI_ACE_Distance (__LaserDesignatorIGUI displayCtrl 123002)
#define __LaserDesignatorIGUI_CA_Distance (__LaserDesignatorIGUI displayCtrl 151)
#define __LaserDesignatorIGUI_LaserOn (__LaserDesignatorIGUI displayCtrl 158)
