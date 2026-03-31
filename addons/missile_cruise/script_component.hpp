#define COMPONENT missile_cruise
#define COMPONENT_BEAUTIFIED Cruise Missile
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MISSILE_CRUISE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MISSILE_CRUISE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MISSILE_CRUISE
#endif

#include "\z\ace\addons\main\script_macros.hpp"

#define MAX_CRUISE_TARGETS 4
