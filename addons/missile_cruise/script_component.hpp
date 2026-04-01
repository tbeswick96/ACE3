#define COMPONENT missile_cruise
#define COMPONENT_BEAUTIFIED Cruise Missile
#include "\z\ace\addons\main\script_mod.hpp"

#define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MISSILE_CRUISE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MISSILE_CRUISE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MISSILE_CRUISE
#endif

#include "\z\ace\addons\main\script_macros.hpp"

#include "idc_defines.hpp"

// Stage IDs for the cruise missile state machine
#define STAGE_LAUNCH    1
#define STAGE_CRUISE    2
#define STAGE_WAYPOINT  3
#define STAGE_APPROACH  4
#define STAGE_POPUP     5
#define STAGE_TERMINAL  6

// Shared physics parameters
#define RATE_USAGE      0.8
#define RESPONSE_TIME   1

// Approach waypoint distance from target (meters)
#define APPROACH_WAYPOINT_DIST 2000

// Launch stage thresholds
#define LAUNCH_MIN_DIST 250
#define LAUNCH_MAX_DESCENT_ANGLE 50
#define DEFAULT_IMPACT_ANGLE 45

#define MAX_CRUISE_TARGETS 4
#define CONTROLS_DISABLED_IN_TOO [\
    CRUISE_PLANNER_IDC_TGT_PREV,\
    CRUISE_PLANNER_IDC_TGT_NEXT,\
    CRUISE_PLANNER_IDC_TGT_EASTING,\
    CRUISE_PLANNER_IDC_TGT_NORTHING,\
    CRUISE_PLANNER_IDC_TGT_HEIGHT,\
    CRUISE_PLANNER_IDC_SET_TGT_TGP,\
    CRUISE_PLANNER_IDC_SET_TGT_MAP,\
    CRUISE_PLANNER_IDC_ADD_TGP,\
    CRUISE_PLANNER_IDC_ADD_MAP,\
    CRUISE_PLANNER_IDC_MOVE_UP,\
    CRUISE_PLANNER_IDC_MOVE_DOWN,\
    CRUISE_PLANNER_IDC_DELETE,\
    CRUISE_PLANNER_IDC_CLEAR_ALL,\
    CRUISE_PLANNER_IDC_LIST\
]
