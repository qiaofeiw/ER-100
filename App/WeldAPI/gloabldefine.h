#ifndef GLOABLDEFINE
#define GLOABLDEFINE
#include<QString>

/***********************************************************************/

#define EROBOWELDSYS_DIR                                             ""
#define EROBOWELDSYS_CURRENT_USER_NAME            "NOP"
#define EROBOWELDSYS_CURRENT_USER_PASSWORD   "NOP"
#define EROBOWELDSYS_CURRENT_USER_TYPE              "User"
#define EROBOWELDSYS_LAST_USER_NAME                    "NOP"
#define EROBOWELDSYS_LAST_USER_TYPE                       "User"
#define EROBOWELDSYS_SCREEN_HEGHT                         480
#define EROBOWELDSYS_SCREEN_WIDTH                         640
#define EROBOWELDSYS_SOFTWAREVREASION               "0.1"
#define EROBOWELDSYS_SOFTWAREAUTHOR                  "陈世豪"
#define EROBOWELDSYS_SOFTWARECOMPANY               "唐山开元特种焊接设备有限公司"
#define EROBOWELDSYS_SOFTWAREDESCRIPTION         "便携式MAG焊接机器人系统"
#define EROBOWELDSYS_THEMEPRIMARYCOLOR            "blue"
#define EROBOWELDSYS_THEMEBACKGROUNDCOLOR   "white"
#define EROBOWELDSYS_THEMEACCENTCOLOR               "yellow"
#define EROBOWELDSYS_BACKLIGHT                                 50

#define EROBOWELDSYS_PLATFORM                                  1//1代表TKSW内核 0代表陈世豪内核

/************************************************************************/

#define EROBOWELDSYS_MODE                                           "Auto"
//#define EROBOWELDSYS_WELDSTART
//平焊单边V型坡口T接头
#define GROOVE_SIGNEL_V_T                                               0
//平焊单边V型坡口平对接

/*
 * 串口配置
 */
#define ERROR_SERIALPORT_OPEN                                      "打开串口失败！"
#define ERROR_SERIALPORT_TIMEOUT                                "串口超时"


/*
 *算法限制条件排序
 */

#define   PI                                                3.141592654
#define   CURRENT_LEFT                          0
#define   CURRENT                                   1
#define   CURRENT_RIGHT                       2
#define   SWING_LEFT_STAYTIME            3
#define   SWING_RIGHT_STAYTIME         4
#define   MAX_HEIGHT                             6
#define   MIN_HEIGHT                             5
#define   SWING_LEFT_LENGTH              7
#define   SWING_RIGHT_LENGTH           8
#define   MAX_SWING_LENGTH              9
#define   SWING_SPACING                      10
#define   K                                                 11
#define   VOLTAGE                                    12
#define   MIN_SPEED                               13
#define   MAX_SPEED                               14
#define   FILL_COE                                   15

#define  BOTTOM_0                                  0
#define  BOTTOM_1                                 16
#define  SECOND                                      32
#define  FILL                                              48
#define  TOP                                              64
#define  LAST                                             80


struct FloorCondition
{       //电流
    int current;
    //电流左侧
    int current_left;
    //电流右侧
    int current_right;
    //电流中间侧
    int current_middle;
    //层高限制
    float maxHeight;
    //层高最小限制
    float minHeight;
    //层高
    float height;
    //层内分道个数
    int num;
    //摆动距离坡口左侧距离
    float swingLeftLength;
    //摆动距离坡口右侧距离
    float swingRightLength;
    //最大摆动宽度
    float maxSwingLength;
    //分道摆动间隔 同一层 不同焊道之间间隔距离
    float weldSwingSpacing;
    //左侧摆动停留时间
    float swingLeftStayTime;
    //右侧摆动停止时间
    float swingRightStayTime;
    //总停留时间
    float totalStayTime;
    //末道填充与初道填充比 也是用于 多层多道
    float k;
    //最大填充量
    float maxFillMetal;
    //最小填充量
    float minFillMetal;
    //最大摆动频率
    float maxSwingHz;
    //最小摆动频率
    float minSwingHz;
    //最大焊接速度
    float maxWeldSpeed;
    //最小焊接速度
    float minWeldSpeed;
    //填充系数
    float fillCoefficient;
};


#endif // GLOABLDEFINE
