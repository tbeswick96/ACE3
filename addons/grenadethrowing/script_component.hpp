#define COMPONENT grenadethrowing
#include "\z\ace\addons\main\script_mod.hpp"

#define DEBUG_MODE_FULL
#define DISABLE_COMPILE_CACHE
// #define CBA_DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_GRENADETHROWING
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_GRENADETHROWING
    #define DEBUG_SETTINGS DEBUG_SETTINGS_GRENADETHROWING
#endif

#include "\z\ace\addons\main\script_macros.hpp"


#define THROWSTYLE_NORMAL_DIR [0, 70, 500]
#define THROWSTYLE_HIGH_DIR [0, 200, 500]
#define THROWSTYLE_HIGH_VEL 8
#define THROWSTYLE_EXTARM_DIR [0, 200, 500]
#define THROWSTYLE_EXTARM_VEL 3

#define CAMERA_OFFSET [0, 0, 0.3]
#define CAMERA_ADJUST [-0.05, -0.12, -0.03]
