#include "\a3\ui_f\hpp\defineCommonGrids.inc"
#include "\a3\ui_f\hpp\defineCommonColors.inc"
#include "idc_defines.hpp"

// Button IDCs only used in this dialog definition
#define CRUISE_PLANNER_IDC_ADD_TGP 1704303
#define CRUISE_PLANNER_IDC_ADD_MAP 1704304
#define CRUISE_PLANNER_IDC_DELETE 1704305
#define CRUISE_PLANNER_IDC_MOVE_UP 1704306
#define CRUISE_PLANNER_IDC_MOVE_DOWN 1704307
#define CRUISE_PLANNER_IDC_SET_TGT_TGP 1704314
#define CRUISE_PLANNER_IDC_SET_TGT_MAP 1704315

class RscListbox;
class RscMapControl;

class GVAR(cruisePlannerUI) {
    idd = CRUISE_PLANNER_IDD;
    movingEnable = 1;
    enableSimulation = 1;
    onLoad = QUOTE(call FUNC(planner_open));
    onUnload = QUOTE(call FUNC(planner_close));
    class controlsBackground {
        class Header: RscText {
            idc = -1;
            text = "Storm Shadow Planner";
            x = QUOTE(3 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(3 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(33 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = GUI_BCG_COLOR;
            moving = 1;
        };
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            onButtonClick = QUOTE(closeDialog 0);
            x = QUOTE(36 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(3 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0.77, 0.15, 0.15, 1};
            colorBackground[] = {0.5, 0, 0, 0.8};
            colorFocused[] = {0.5, 0, 0, 0.8};
            style = 2;
        };
        class Background: RscText {
            idc = -1;
            x = QUOTE(3 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(4.1 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(34 * GUI_GRID_W);
            h = QUOTE(17.2 * GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
        };
    };
    class controls {
        // Map control - left side
        class PlannerMap: RscMapControl {
            idc = CRUISE_PLANNER_IDC_MAP;
            x = QUOTE(3.5 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(4.5 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(18 * GUI_GRID_W);
            h = QUOTE(15 * GUI_GRID_H);
            drawObjects = 0;
        };

        // --- TARGET SECTION (right side, top) ---
        class TargetHeader: RscText {
            idc = -1;
            text = "TARGET";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(4.5 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(14.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0.2, 0, 0, 0.6};
            style = 2;
        };

        // Target cycling controls
        class TgtPrev: RscButton {
            idc = CRUISE_PLANNER_IDC_TGT_PREV;
            text = "<<";
            onButtonClick = QUOTE([-1] call FUNC(planner_cycleTarget));
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0, 0, 0, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class TgtLabel: RscText {
            idc = CRUISE_PLANNER_IDC_TGT_LABEL;
            text = "TGT 1";
            x = QUOTE(24.2 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 1};
            style = 2;
        };
        class TgtNext: RscButton {
            idc = CRUISE_PLANNER_IDC_TGT_NEXT;
            text = ">>";
            onButtonClick = QUOTE([1] call FUNC(planner_cycleTarget));
            x = QUOTE(27.4 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(5.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0, 0, 0, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };

        class EastingLabel: RscText {
            idc = -1;
            text = "Easting";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(6.9 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class TgtEasting: RscEdit {
            idc = CRUISE_PLANNER_IDC_TGT_EASTING;
            text = "";
            x = QUOTE(25.2 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(6.9 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
            maxChars = 5;
        };
        class NorthingLabel: RscText {
            idc = -1;
            text = "Northing";
            x = QUOTE(29 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(6.9 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class TgtNorthing: RscEdit {
            idc = CRUISE_PLANNER_IDC_TGT_NORTHING;
            text = "";
            x = QUOTE(32.7 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(6.9 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
            maxChars = 5;
        };

        class HeightLabel: RscText {
            idc = -1;
            text = "Height (m)";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(8.1 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class TgtHeight: RscEdit {
            idc = CRUISE_PLANNER_IDC_TGT_HEIGHT;
            text = "";
            x = QUOTE(25.7 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(8.1 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
            maxChars = 5;
        };

        class AngleLabel: RscText {
            idc = -1;
            text = "Impact Angle";
            x = QUOTE(29 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(8.1 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(4.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class TgtAngle: RscEdit {
            idc = CRUISE_PLANNER_IDC_TGT_ANGLE;
            text = "";
            x = QUOTE(33.7 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(8.1 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
            maxChars = 2;
        };

        class HeadingLabel: RscText {
            idc = -1;
            text = "Atk Heading";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(9.3 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(4.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class TgtHeading: RscEdit {
            idc = CRUISE_PLANNER_IDC_TGT_HEADING;
            text = "";
            x = QUOTE(26.7 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(9.3 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
            maxChars = 3;
        };

        // Set target buttons — own row, same width as Add WP buttons
        class SetTgtTGP: RscButton {
            idc = CRUISE_PLANNER_IDC_SET_TGT_TGP;
            text = "Set TGT: TGP";
            onButtonClick = QUOTE(call FUNC(planner_setTargetTGP));
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(10.5 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = GUI_BCG_COLOR;
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class SetTgtMap: RscButton {
            idc = CRUISE_PLANNER_IDC_SET_TGT_MAP;
            text = "Set TGT: Map";
            onButtonClick = QUOTE(call FUNC(planner_setTargetMap));
            x = QUOTE(27.3 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(10.5 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = GUI_BCG_COLOR;
            colorFocused[] = {0, 0, 0, 0.8};
        };

        // Cruise altitude
        class CruiseModeLabel: RscText {
            idc = -1;
            text = "Cruise Alt";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(11.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(4.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };
        class CruiseModeCombo: RscCombo {
            idc = CRUISE_PLANNER_IDC_CRUISE_MODE;
            x = QUOTE(26.7 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(11.7 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(9.8 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.8};
        };

        // --- WAYPOINT SECTION (right side, middle) ---
        class WaypointList: RscListbox {
            idc = CRUISE_PLANNER_IDC_LIST;
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(12.9 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(14.5 * GUI_GRID_W);
            h = QUOTE(4.3 * GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0.6};
        };

        // Info text
        class InfoText: RscText {
            idc = CRUISE_PLANNER_IDC_INFO;
            text = "0 entries";
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(17.4 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(14.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorBackground[] = {0, 0, 0, 0};
        };

        // Waypoint add buttons
        class AddFromTGP: RscButton {
            idc = CRUISE_PLANNER_IDC_ADD_TGP;
            text = "Add WP: TGP";
            onButtonClick = QUOTE(call FUNC(planner_addFromTGP));
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(18.6 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = GUI_BCG_COLOR;
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class AddFromMap: RscButton {
            idc = CRUISE_PLANNER_IDC_ADD_MAP;
            text = "Add WP: Map";
            onButtonClick = QUOTE(call FUNC(planner_addFromMap));
            x = QUOTE(27.3 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(18.6 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = GUI_BCG_COLOR;
            colorFocused[] = {0, 0, 0, 0.8};
        };

        // Waypoint management buttons
        class MoveUp: RscButton {
            idc = CRUISE_PLANNER_IDC_MOVE_UP;
            text = "Up";
            onButtonClick = QUOTE([-1] call FUNC(planner_moveWaypoint));
            x = QUOTE(22 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(19.8 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2.2 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0.15, 0.15, 0.15, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class MoveDown: RscButton {
            idc = CRUISE_PLANNER_IDC_MOVE_DOWN;
            text = "Down";
            onButtonClick = QUOTE([1] call FUNC(planner_moveWaypoint));
            x = QUOTE(24.4 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(19.8 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0.15, 0.15, 0.15, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class Delete: RscButton {
            idc = CRUISE_PLANNER_IDC_DELETE;
            text = "Delete";
            onButtonClick = QUOTE(call FUNC(planner_deleteWaypoint));
            x = QUOTE(27.1 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(19.8 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(2.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0.15, 0.15, 0.15, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class ClearAll: RscButton {
            idc = -1;
            text = "Clear All";
            onButtonClick = QUOTE(call FUNC(planner_clearAll));
            x = QUOTE(29.8 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(19.8 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0, 0, 1};
            colorBackground[] = {0.5, 0, 0, 0.8};
            colorFocused[] = {0, 0, 0, 0.8};
        };
        class SaveButton: RscButton {
            idc = -1;
            text = "Save";
            onButtonClick = QUOTE(closeDialog 0);
            x = QUOTE(33 * GUI_GRID_W + GUI_GRID_CENTER_X);
            y = QUOTE(19.8 * GUI_GRID_H + GUI_GRID_CENTER_Y);
            w = QUOTE(3.5 * GUI_GRID_W);
            h = QUOTE(GUI_GRID_H);
            colorActive[] = {0, 0.4, 0, 1};
            colorBackground[] = {0, 0.5, 0, 0.8};
            colorFocused[] = {0, 0.5, 0, 0.8};
        };
    };
};
