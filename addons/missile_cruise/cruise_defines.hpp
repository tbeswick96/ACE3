// Stage IDs for the cruise missile state machine
#define STAGE_LAUNCH    1
#define STAGE_CRUISE    2
#define STAGE_WAYPOINT  3
#define STAGE_APPROACH  4
#define STAGE_POPUP     5
#define STAGE_TERMINAL  6

// Shared physics parameters
#define RATE_USAGE      0.9
#define RESPONSE_TIME   1

// Approach waypoint distance from target (meters)
#define APPROACH_WAYPOINT_DIST 2000

// Launch stage thresholds
#define LAUNCH_MIN_DIST 250
#define LAUNCH_MAX_DESCENT_ANGLE 50
#define DEFAULT_IMPACT_ANGLE 45
