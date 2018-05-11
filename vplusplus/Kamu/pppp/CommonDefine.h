//
//  CommonDefine.h
//  P2PCamera
//
//  Created by user on 16/3/25.
//
//

#ifndef CommonDefine_h
#define CommonDefine_h

#pragma mark--------start enum define---------
enum eDelegateType{
//    YUV_DATA_DELEGATE,
    MAIN_MONITOR_DELEGATE,
    CAMERA_EDIT_PARAM_DELEGATE,
    PLAY_STATUS_DELEGATE,
    DOORBELL_CALLER_CAMERAVIEW_DELEGATE,
    DOORBELL_CALLER_WATCHVIEW_DELEGATE,
    DOORBELL_CALLER_FIRSTVIEW_DELEGATE,
    P2P_STATUS_DELEGATE,
    P2P_CAMERA_VIEW_STATUS_DELEGATE,
    SDCARD_STATUS_DELEGATE,
    TIME_ZONE_DELEGATE,
    DELEGATE_COUNT,
    PASS_WORD_CHANGE,
    DEVICE_CODE,
};

enum eSysDataType{
    DATA_SEND_AUDIO,
    DATA_PLAY_AUDIO,
    DATA_DEVICE_TYPE,
};


enum DeviceStatus{
    PPPP_STATUS_DISCONNECTED=0,     // 连接断开
    PPPP_STATUS_CONNECTING,         // 连接中
    PPPP_STATUS_CONNECTED,          // 已经连接
    PPPP_STATUS_ID_INVALID,         // 无效ID
    PPPP_STATUS_DEVICE_OFFLINE,     // 设备离线
    PPPP_STATUS_LOCAL_SESSION_OVERLIMIT,  // 本地会话超限
    PPPP_STATUS_REMOTE_SESSION_OVERLIMIT, // 对端会话超限
    PPPP_STATUS_SESSIONSETUP_TIMEOUT,  // 会话建立超时 7
    PPPP_STATUS_ID_OUTOFDATE,          // ID过期
    PPPP_STATUS_USER_AUTHENTICATING,   // 正在验证中
    PPPP_STATUS_USER_AUTHENTICATED,    // 验证成功
    PPPP_STATUS_USER_INVALID,          // 无效用户
    PPPP_STATUS_UNKNOWN_ERROR,         // 未知错误
    PPPP_STATUS_NOT_INITIALIZED,       // 未初始化
    PPPP_STATUS_DISCONNECTING,         // 正在断开中
    PPPP_STATUS_USER_INAUTHENTICATED,  // 未验证
    PPPP_STATUS_USER_NOT_LOGIN,	       // 未登录
    PPPP_STATUS_UNKNOWN = 0xffffffff, //17
};


enum CamCtrl{
    VIDEO_PARAM_TYPE_DEFAULT=0,//恢复到所有视频参数缺省值
    VIDEO_PARAM_TYPE_RESOLUTION,//分辨率
    VIDEO_PARAM_TYPE_BRIGHTNESS,//亮度
    VIDEO_PARAM_TYPE_CONTRAST,//对比度
    VIDEO_PARAM_TYPE_SATURATION,//彩饱和度
    VIDEO_PARAM_TYPE_SHARPNESS,//锐利
    VIDEO_PARAM_TYPE_FRAMERATE,//帧率
    VIDEO_PARAM_TYPE_BITRATE,//码率
    VIDEO_PARAM_TYPE_ROTATE,//图像镜像和返转0正常,1左右,2上下,3左右上下
    VIDEO_PARAM_TYPE_IRCUT,//ircut控制 0->自动，1->enable,2->关闭
    VIDEO_PARAM_TYPE_OSD,//0->关闭1->打开
    VIDEO_PARAM_TYPE_MOVEDETECTION,//0->关闭1->打开
    VIDEO_PARAM_TYPE_MODE,//flicker
};


enum AudioCtrl{
    AUDIO_PARAM_TYPE_INPUTGAIN=5,
    AUDIO_PARAM_TYPE_OUTPUTGAIN=6,
};


enum CamRotate{
    PARAM_VALUE_CAMERA_ROTATE_DEFAULT,//原位
    PARAM_VALUE_CAMERA_ROTATE_V,//垂直旋转
    PARAM_VALUE_CAMERA_ROTATE_H,//水平旋转
    PARAM_VALUE_CAMERA_ROTATE_VH //水平+垂直旋转
};

enum CamRovelution{
    PARAM_VALUE_CAMERA_ROVELUTION_MAIN,  // 标清
    PARAM_VALUE_CAMERA_ROVELUTION_SUB1,  // 流畅
    PARAM_VALUE_CAMERA_ROVELUTION_SUB2=3 // 高清
};

//SD卡状态
enum SdcardStatus{
    SD_STATUS_UNEXIST=0, //sd 卡不存在
    SD_STATUS_UNFORMAT,  //sd 未格式化
    SD_STATUS_BADFORMAt, //sd 不良状态需修复
    SD_STATUS_DIRTY,
    SD_STATUS_OK,        //sd 状态正常
    SD_STATUS_INITIALIZE_FAILED,
    SD_STATUS_NOT_INITIALIZED,
    SD_STATUS_RECORDING,  //sd 录像中
    SD_STATUS_RECSTOP,    //sd 录像停止
    SD_STATUS_RECFAILED,  //sd 写失败
    SD_STATUS_RW_FAILED,
    SD_STATUS_TIME_PROBLEM,
    SD_STATUS_SPACE_INSUFFIENT,
    SD_STATUS_OPR_NORESULT,
    SD_STATUS_OPR_COLLISION
};


enum LogType{
    XQLOG_TYPE_ALL,      //所有日志
    XQLOG_TYPE_SYSTEM,   //系统日志
    XQLOG_TYPE_ALARM,    //告警日志
    XQLOG_TYPE_OTHER     //未知类型
};


enum eDeviceType{
    TYPE_IP02 = 0,
    TYPE_YTJ = 1,
    TYPE_CAMERA = 2,
};

enum LogAlarmType{
    DOOR_BELL_CALL_IN,              // 呼叫---设备休眠
    XQLOG_ALARMTYPE_MOVEDETECT=1,   // 移动侦测
    DOOR_BELL_CALL_IN_2,            // 呼叫---设备在线
    XQLOG_ALARMTYPE_GPIO,           // 低电量报警
    XQLOG_ALARMTYPE_ADC,
    XQLOG_ALARMTYPE_WIFI,
    XQLOG_ALARMTYPE_SERIAL,
    XQLOG_ALARMTYPE_OTHER,
    DOOR_BELL_CALL_ALREADY_REPLY=8,
    DOOR_BELL_CALL_OEVER=9,
    DOOR_BELL_PIR_TRIGGER_ALARM,
    DOOR_BELL_TAMPER_ALARM,
    DOOR_BELL_BATTERY_ALARM,
    DOOR_BELL_EXTERNAL_POWER_ALARM,
    DOOR_BELL_CALL_IN_ANSWER=111,
};

enum eRecordType{
    DOOR_BELL_CALL_NO = 0,  //呼叫未接听
    DOOR_BELL_CALL_OK = 1,  //呼叫已接听
    
    DOOR_BELL_DETECTION_NO = 2,  //移动侦测未接听
    DOOR_BELL_DETECTION_OK = 3,  //移动侦测已查看
    
    DOOR_BELL_ALARM_DISMANTLE_NO = 4,  //防拆报警未接听
    DOOR_BELL_ALARM_DISMANTLE_OK = 5,  //防拆报警已查看
    
    DOOR_BELL_ALARM_433_NO = 6,   //433报警未接听
    DOOR_BELL_ALARM_433_OK = 7,   //433报警已查看
    
    DOOR_BELL_ALARM_BATTERY_NO = 8,    //低电量报警未接听
    DOOR_BELL_ALARM_BATTERY_OK = 9,      //低电量报警已查看
};


typedef enum _TableStyle{
    TABLE_PICTURE = 1,
    TABLE_VIDEO,
    TABLE_MESSAGE,
    TABLE_DOWNLOAD,
}TableStyle;


//device setting item
enum SettingItem{
    CONFITEMTYPE_TZ, // 恢复时区
    CONFITEMTYPE_IO,
    CONFITEMTYPE_IMG,
    CONFITEMTYPE_CMOS,
    CONFITEMTYPE_AUDIO,
    CONFITEMTYPE_VIDEO,
    CONFITEMTYPE_USER,
    CONFITEMTYPE_ALARM,
    CONFITEMTYPE_UPGRADE,
    CONFITEMTYPE_RECPOLICY,  // 恢复SD卡
    CONFITEMTYPE_PUSH,
    CONFITEMTYPE_P2P,
    CONFITEMTYPE_DETECT,
    CONFITEMTYPE_OSD,
    CONFITEMTYPE_WIFI,  // 恢复WiFi
    CONFITEMTYPE_OPR,   // 恢复运行设置
    CONFITEMTYPE_GPIO,
    CONFITEMTYPE_SERIAL,
    CONFITEMTYPE_RESCH=19
};

enum PtzCtrlType{
    DIRECTION = 0,   //云台方向
    PREFAB = 1       //预置位
};


// AVIOCTRL PTZ Command Value
typedef enum
{
    AVIOCTRL_PTZ_STOP					= 0,
    AVIOCTRL_PTZ_UP						= 1,
    AVIOCTRL_PTZ_DOWN					= 2,
    AVIOCTRL_PTZ_LEFT					= 3,
    AVIOCTRL_PTZ_LEFT_UP				= 4,
    AVIOCTRL_PTZ_LEFT_DOWN				= 5,
    AVIOCTRL_PTZ_RIGHT					= 6,
    AVIOCTRL_PTZ_RIGHT_UP				= 7,
    AVIOCTRL_PTZ_RIGHT_DOWN				= 8,
    AVIOCTRL_PTZ_AUTO					= 9,
    AVIOCTRL_PTZ_SET_POINT				= 10,
    AVIOCTRL_PTZ_CLEAR_POINT			= 11,
    AVIOCTRL_PTZ_GOTO_POINT				= 12,
    
    AVIOCTRL_PTZ_SET_MODE_START			= 13,
    AVIOCTRL_PTZ_SET_MODE_STOP			= 14,
    AVIOCTRL_PTZ_MODE_RUN				= 15,
    
    AVIOCTRL_PTZ_MENU_OPEN				= 16,
    AVIOCTRL_PTZ_MENU_EXIT				= 17,
    AVIOCTRL_PTZ_MENU_ENTER				= 18,
    
    AVIOCTRL_PTZ_FLIP					= 19,
    AVIOCTRL_PTZ_START					= 20,
    
    AVIOCTRL_LENS_APERTURE_OPEN			= 21,
    AVIOCTRL_LENS_APERTURE_CLOSE		= 22,
    
    AVIOCTRL_LENS_ZOOM_IN				= 23,
    AVIOCTRL_LENS_ZOOM_OUT				= 24,
    
    AVIOCTRL_LENS_FOCAL_NEAR			= 25,
    AVIOCTRL_LENS_FOCAL_FAR				= 26,
    
    AVIOCTRL_AUTO_PAN_SPEED				= 27,
    AVIOCTRL_AUTO_PAN_LIMIT				= 28,
    AVIOCTRL_AUTO_PAN_START				= 29,
    
    AVIOCTRL_PATTERN_START				= 30,
    AVIOCTRL_PATTERN_STOP				= 31,
    AVIOCTRL_PATTERN_RUN				= 32,
    
    AVIOCTRL_SET_AUX					= 33,
    AVIOCTRL_CLEAR_AUX					= 34,
    AVIOCTRL_MOTOR_RESET_POSITION		= 35,
    
    AVIOCTRL_PTZ_LEFT_RIGHT_AUTO		= 36,	// 左右巡航
    AVIOCTRL_PTZ_UP_DOWN_AUTO			= 37	// 上下巡航
}ENUM_PTZCMD;


typedef enum {
    MEDIA_CODEC_UNKNOWN			= 0x00,
    MEDIA_CODEC_VIDEO_MPEG4		= 0x4C,
    MEDIA_CODEC_VIDEO_H263		= 0x4D,
    MEDIA_CODEC_VIDEO_H264		= 0x4E,
    MEDIA_CODEC_VIDEO_MJPEG		= 0x4F,
    
    MEDIA_CODEC_AUDIO_AAC       = 0x88,   // 2014-07-02 add AAC audio codec definition
    MEDIA_CODEC_AUDIO_G711U     = 0x89,   //g711 u-law
    MEDIA_CODEC_AUDIO_G711A     = 0x8A,   //g711 a-law
    MEDIA_CODEC_AUDIO_ADPCM     = 0X8B,
    MEDIA_CODEC_AUDIO_PCM		= 0x8C,
    MEDIA_CODEC_AUDIO_SPEEX		= 0x8D,
    MEDIA_CODEC_AUDIO_MP3		= 0x8E,
    MEDIA_CODEC_AUDIO_G726      = 0x8F,
    MEDIA_CODEC_AUDIO_OPUS      = 0xE1,
    
}ENUM_CODECID;

enum eLockCondition{
    NO_DATA,
    LOCKED,
    UNLOCKED,
};

enum eScheduleType{
    TYPE_MOTION_ALARM,
    TYPE_AUTO_RECORDING,
};

enum ePUSH_DEL_TYPE{
    STOP_PUSH_DEL,
    START_PUSH_DEL,
};

enum eAddType{
    TYPE_MANUAL,
    TYPE_AUTO,
    TYPE_RQCODE,
};

enum eAudioType{
    AUDIO_TYPE_NONE,
    AUDIO_TYPE_PCM,
    AUDIO_TYPE_ADPCM,
    AUDIO_TYPE_G711,
    AUDIO_TYPE_OPUS,
};
enum eTimerType{
    TIMER_TYPE_NIGHT_MODE,
    TIMER_TYPE_MANUAL,
    TIMER_TYPE_ALL_DAY,
    TIMER_TYPE_OFF,
};

enum eDMS_TIME_ZONE_E{
    DMS_GMT_N12 = 0, //(GMT-12:00) International Date Line West
    DMS_GMT_N11, //(GMT-11:00) Midway Island,Samoa
    DMS_GMT_N10, //(GMT-10:00) Hawaii
    DMS_GMT_N09, //(GMT-09:00) Alaska
    DMS_GMT_N08, //(GMT-08:00) Pacific Time (US&amp;Canada)
    DMS_GMT_N07, //(GMT-07:00) Mountain Time (US&amp;Canada)
    DMS_GMT_N06, //(GMT-06:00) Central Time (US&amp;Canada)
    DMS_GMT_N05, //(GMT-05:00) Eastern Time(US&amp;Canada)
    DMS_GMT_N0430, //(GMT-04:30) Caracas
    DMS_GMT_N04, //(GMT-04:00) Atlantic Time (Canada)
    DMS_GMT_N0330, //(GMT-03:30) Newfoundland
    DMS_GMT_N03, //(GMT-03:00) Georgetown, Brasilia
    DMS_GMT_N02, //(GMT-02:00) Mid-Atlantic
    DMS_GMT_N01, //(GMT-01:00) Cape Verde Islands, Azores
    DMS_GMT_00, //(GMT+00:00) Dublin, Edinburgh, London
    DMS_GMT_01, //(GMT+01:00) Amsterdam, Berlin, Rome, Paris
    DMS_GMT_02, //(GMT+02:00) Athens, Jerusalem, Istanbul
    DMS_GMT_03, //(GMT+03:00) Baghdad, Kuwait, Moscow
    DMS_GMT_0330, //(GMT+03:30) Tehran
    DMS_GMT_04, //(GMT+04:00) Caucasus Standard Time
    DMS_GMT_0430, //(GMT+04:30) Kabul
    DMS_GMT_05, //(GMT+05:00) Islamabad, Karachi, Tashkent
    DMS_GMT_0530, //(GMT+05:30) Madras, Bombay, New Delhi
    DMS_GMT_0545, //(GMT+05:45) Kathmandu
    DMS_GMT_06, //(GMT+06:00) Almaty, Novosibirsk, Dhaka
    DMS_GMT_0630, //(GMT+06:30) Yangon
    DMS_GMT_07, //(GMT+07:00) Bangkok, Hanoi, Jakarta
    DMS_GMT_08, //(GMT+08:00) Beijing, Urumqi, Singapore
    DMS_GMT_09, //(GMT+09:00) Seoul, Tokyo, Osaka, Sapporo
    DMS_GMT_0930, //(GMT+09:30) Adelaide, Darwin
    DMS_GMT_10, //(GMT+10:00) Melbourne, Sydney, Canberra
    DMS_GMT_11, //(GMT+11:00) Magadan, Solomon Islands
    DMS_GMT_12, //(GMT+12:00) Auckland, Wellington, Fiji
    DMS_GMT_13, //(GMT+13:00) Nuku'alofa
};

enum ePresentType{
    TYPE_NORMAL_MONITOR,
    TYPE_ALARM_DETECT,
};
enum eMediaRunningStatus{
    STATUS_IDEL,
    STATUS_STARTING,
    STATUS_FINISH,
};

enum eConnectStatus{
    CS_NOT_CONNECT,
    CS_CONNECTED,
    CS_DELETE,
};


//msgtype
#define MSG_NOTIFY_TYPE_PPPP_STATUS 0   	/* ¡¨Ω”◊¥Ã¨ */
#define MSG_NOTIFY_TYPE_PPPP_MODE 1   		/* ¡¨Ω”ƒ£ Ω */
#define MSG_NOTIFY_TYPE_STREAM_TYPE 2


//#define GK_IPC


#define PARTITION_STRING "#_edwin_#"


#endif /* CommonDefine_h */
