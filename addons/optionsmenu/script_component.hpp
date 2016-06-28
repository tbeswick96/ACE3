#define COMPONENT optionsmenu
#define COMPONENT_BEAUTIFIED Options Menu

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define CBA_DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#include "\z\ace\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_OPTIONSMENU
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_OPTIONSMENU
    #define DEBUG_SETTINGS DEBUG_SETTINGS_OPTIONSMENU
#endif

#include "\z\ace\addons\main\script_macros.hpp"

#define MENU_TAB_OPTIONS 0
#define MENU_TAB_COLORS 1

#define MENU_TAB_SERVER_OPTIONS 10
#define MENU_TAB_SERVER_COLORS 11
#define MENU_TAB_SERVER_VALUES 12
