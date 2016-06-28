#define COMPONENT markers
#define COMPONENT_BEAUTIFIED Markers
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define CBA_DEBUG_SYNCHRONOUS
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MARKERS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_ENABLED_MARKERS
    #define DEBUG_SETTINGS DEBUG_ENABLED_MARKERS
#endif

#include "\z\ace\addons\main\script_macros.hpp"

#define CHANNEL_NAMES [ \
    localize "str_channel_global", \
    localize "str_channel_side", \
    localize "str_channel_command", \
    localize "str_channel_group", \
    localize "str_channel_vehicle", \
    localize "str_channel_direct" \
]
