/*
 * AVIOCTRLDEFs.h
 *	Define AVIOCTRL Message Type and Context
 *  Created on: 2011-08-12
 *  Author: TUTK
 *
 */


#ifndef _AVIOCTRL_DEFINE_H_
#define _AVIOCTRL_DEFINE_H_

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Message Type Define//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

#pragma mark ----------------发送接收参数识别--------------

// AVIOCTRL Message Type
typedef enum 
{
    
    // for IP02/IPC product
    IOTYPE_USER_IPCAM_SET_PUSH_REQ              = 0x802,	// 消息推送注册
    IOTYPE_USER_IPCAM_SET_PUSH_RESP             = 0x803,	// 消息推送注册应答
    
    IOTYPE_USER_IPCAM_DEL_PUSH_REQ              = 0x804,	// 消息推送注销
    IOTYPE_USER_IPCAM_DEL_PUSH_RESP             = 0x805,	// 消息推送注销应答
    
    CMD_CAMPARAM_SET		        = 0x5012,   //设置摄像机　CameraCtrlBean
    CMD_CAMPARAM_GET	            = 0x5003,   //获取摄像机当前参数 ImageParamsBean
    CMD_PTZ_SET			            = 0x5049,   //云台控制
    
    CMD_AUDIO_PARAM_SET             = 0x3004,   //设置音频
    CMD_AUDIO_PARAM_GET             = 0x3005,   //获取音频
    
    CMD_SYSTEM_OPRPOLICY_SET	    = 0x1031,   //设置系统运行策略　参见SysOprBean
    CMD_SYSTEM_OPRPOLICY_GET	    = 0x1032,   //获取系统运行策略
    
    CMD_SYSTEM_SHUTDOWN		        = 0x1010,   //系统关闭
    CMD_SYSTEM_REBOOT		        = 0x1011,   //系统重起
    
    CMD_SYSTEM_DATETIME_SET	        = 0x1040,   //设置系统时间 DateBean
    CMD_SYSTEM_DATETIME_GET         = 0x1041,   //获取系统时间
    
    CMD_SYSTEM_DEFAULTSETTING_IMPORT    = 0x1000,   //导入缺省配置
    CMD_SYSTEM_DEFAULTSETTING_EXPORT	= 0x1001,   //导出缺省配置
    CMD_SYSTEM_DEFAULTSETTING_RECOVERY	= 0x1002,   //恢复缺省配置
    CMD_SYSTEM_ITEMDEFAULTSETTING_RECOVERY = 0x1003,//单项恢复缺省配置
    CMD_SYSTEM_CURRENTSETTING_EXPORT	= 0x1004,   //导出当前配置
    CMD_SYSTEM_CURRENTSETTING_IMPORT	= 0x1005,   //导入当前配置
    CMD_SYSTEM_DEFAULTSETTING_CREATE    = 0x1006,   //创建缺省配置
    CMD_SYSTEM_FIRMWARE_UPGRAD          = 0x1007,   //固件升级
    CMD_SYSTEM_STATUS_GET               = 0x1008,   //系统状态获取
    
    
    CMD_SD_FORMAT		            = 0x2000,   //格化设备SD卡
    CMD_SD_RECPOLICY_SET	        = 0x2001,   //录像策略 SdStoragePolicyBean
    CMD_SD_RECPOLICY_GET	        = 0x2002,   //获取录像存储策略
    CMD_SD_RECORDING_NOW	        = 0x2003,   //实时录像  SdRecCtrlBean
    CMD_SD_INFO_GET	                = 0x2004,   //获取SD卡相关信息 SdInfoBean
    CMD_SD_RECORDFILE_GET           = 0x2005,   //获取Sd卡录像列表  SdRecfileSearchBean
    CMD_SD_RECORDSCH_GET		    = 0x2006,   //获取SD卡录像计划
    CMD_SD_RECORDSCH_SET		    = 0x2007,   //设置SD卡录像计划
    CMD_SD_RETRIVEL		            = 0x2008,   //SD文件系统修复
    
    CMD_SYSTEM_USER_CHK	            = 0x1020,   //用户验证
    CMD_SYSTEM_USER_SET		        = 0x1021,   //用户设置
    CMD_SYSTEM_USER_GET		        = 0x1022,   //用户获取
    
    CMD_PUSHPARAM_SET	            = 0x1200,   //设置PUSH参数　PushBean
    CMD_PUSHPARAM_GET               = 0x1201,   //获取
    CMD_PUSHPARAM_DEL	            = 0x1203,   //删除
    
    CMD_LOG_GET			            = 0x5004,   //获取日志　LogSearchConditionBean
    CMD_LOG_SET				        = 0x500d,   //设置日志LogSettingBean
    
    CMD_FILETRANSFER_LOCALPATH      = 0x4001,
    CMD_FILETRANSFER_GET		    = 0x4002,
    CMD_FILETRANSFER_PUT		    = 0x4003,
    CMD_FILETRANSFER_SET		    = 0x4004,   //删除等
    CMD_FILETRANSFER_FILELIST_GET	= 0x4005,
    
    
    //video ctrl
    CMD_VIDEO_PLAY		            = 0x3010,   //播放
    CMD_VIDEO_STOP		            = 0x3011,   //暂停
    CMD_VIDEO_STARTPLAYBACK	        = 0x3012,   //回放
    CMD_VIDEO_STOPPLAYBACK	        = 0x3013,
    CMD_DEV_RECORD_PLAYBACK_SEEK	= 0x3014, //ReWind
    CMD_DEV_RECORD_PLAYBACK_SPEED		=0x3015,
    
    CMD_DOORBELL_CALL_OPEN	      =0x3020,//呼叫会话打开
    CMD_DOORBELL_CALL_CLOSE	      =0x3021,//呼叫会话关闭
    
    CMD_DOORBELL_CALL_ACCEPT	=0x3022,//呼叫接受
    CMD_DOORBELL_CALL_REJECT	=0x3023,//呼叫拒绝
    
    
    CMD_NET_WIFISETTING_SET		    = 0x1130,   //设置wifi NetWifiSettingBean
    CMD_NET_WIFISETTING_GET		    = 0x1131,   //获取wifi配置
    CMD_NET_WIFI_SCAN		        = 0x1132,   //让设备扫描wifi　NetWifiScanBean
    CMD_NET_WIREDSETTING_SET		= 0x1133,   //设置有线 NetWiredSettingBean
    CMD_NET_WIREDSETTING_GET		= 0x1134,   //获取有线信息
    
    
     CMD_ALARM_IO_INPUT_SET		=	0x1112,//关联gpio口行为gpioAction_t
     CMD_ALARM_IO_INPUT_GET		=	0x1113,//关联gpio口行为gpioAction_t//
     CMD_ALARM_ADC_SET			= 0x1101,//模数接口参数设置
     CMD_ALARM_ADC_GET			= 0x1102,//模数接口参数设置
     CMD_ALARM_MOTION_GET		= 0x5061,  //移动侦测设置
     CMD_ALARM_MOTION_SET       = 0x5062,
    
    
    
    
    IOTYPE_USER_CMD_MAX
}ENUM_AVIOCTRL_MSGTYPE;


//长度定义
#define LEN_16_SIZE                    16
#define LEN_24_SIZE                    24
#define LEN_32_SIZE                    32
#define LEN_48_SIZE                    48
#define LEN_64_SIZE                    64
#define LEN_128_SIZE                128
#define LEN_256_SIZE                 256
#define LEN_512_SIZE                512
#define LEN_1024_SIZE                1024
#define LEN_1536_SIZE                1536
#define LEN_1920_SIZE                1920
#define LEN_2048_SIZE                2048
#define LEN_4096_SIZE                4096
#define LEN_8192_SIZE                8192

/***************************************************
 1.系统相关数据结构
 ****************************************************/
#define SYSTEM_USER_ACCOUNT_LEN        LEN_32_SIZE
#define SYSTEM_USER_PASSWORD_LEN    LEN_128_SIZE
#define SYSTEM_DEV_NAME_LEN            LEN_64_SIZE
#define SYSTEM_USER_TICKET_LEN        4
#define P2P_ID_LEN                    LEN_24_SIZE
#define FILE_PATH_MAX_LEN            LEN_128_SIZE
#define SYSTEM_USER_MAX_NMB            3
#define P2P_SVRSTR_LEN                LEN_512_SIZE


//系统状态信息 CMD_SYSTEM_STATUS_GET
typedef struct tag_devStatus{
    int swVer;//设备软件版本
    int hwVer;//设备硬件版本
//    int devType;//设备类型
    int timeZone;//时间
    unsigned int lastShutdownTime;//最后日志时间
    unsigned int sysUptime;//当次系统启动耗时,从boot算起
    unsigned int netUptime;//当次连网耗时,从boot算起
    
    char devName[SYSTEM_DEV_NAME_LEN];//设备名
//    char p2pID[LEN_24_SIZE];//设备ID
    
    unsigned char    sdStatus;//SD卡状态
    unsigned char    p2pStatus;//p2p状态,是否连接外网,当前会话数目
    unsigned char    connType;//wifi使能否,0-->无线，１有线
    unsigned char    recEnableOnStart;//开机录像使能否
    unsigned char    picCapOnStart;//开机录像使能
    unsigned char    ircut;//ircut
    unsigned char    pushEnable;
    unsigned char    alarmEnable;
    //net
    unsigned char    wifiMode;      //wifimode
    unsigned char    dhcp;     //!< 1->dhcp to get dns(dhcp_ip_enable must be 1),  0->static dns
    unsigned char    mac[6];//mac地址
    unsigned int    ipAddr;//ip地址
    unsigned int    netmask;//网络腌码
    //sd
    unsigned int    lastRecTime;    //最后录像时间
    unsigned int    sdTotalSize;//sd全容量
    unsigned int    sdUsedSize;//sd使用容量
}devStatus_t;

#pragma mark ------------基本数据结构-------------------
// 消息推送注册使用的数据结构
typedef struct tag_pushParam{
    char SetType;
    char device_token[65];
    int environment; //1 开发环境   其他 生产环境
    int pushType;
    int validity;
    //---------jpush----------
    char appkey[64];
    char master[64];
    char alias[64];
    int type;
    //-------------bpush----------
    char apikey[64];
    char ysecret_key[64];
    char channel_id[64];
    //-------------xpush------------
    unsigned int access_id;
    char xsecret_key[64];
    
}pushParam_t, *pPushParam_t;

// 摄像头参数使用的数据结构
typedef struct tag_camCtrl_EX{
    int paramType;
    int paramValue;
}camCtrl_t_EX;

//设置PTZ的数据结构
typedef struct tag_ptzCtrl{
    int param;
    int value;
    int step;
}ptzParamSet_t;

//设置音频的数据结构
typedef struct tag_audioCtrl{
    int param;
    int value;
}audioCtrl_t;

//audio参数
typedef struct{
    int		Profile;					//兼容ONVIF profile[0-2]代表编码通道号[0-2]
    int		Source;						//音源采样率acSampleRate_e
    int		Mute;						//静音
    int		Codec;						//编码类型0-PCMU 8-PCMA 21-G726
    int		BitWidth;					//acBitwidth_e
    int		InputGain;					//0~100
    int		OutputGain;					//0~100
}audioParam_t;

//audio参数设置
typedef struct{
    int paramType;//audioParamType_e
    union{
        int 	Profile;					//兼容ONVIF profile[0-2]代表编码通道号[0-2]
        int 	Source; 					//音源采样率acSampleRate_e
        int 	Mute;						//静音
        int 	Codec;						//编码类型0-PCMU 8-PCMA 21-G726
        int 	BitWidth;					//acBitwidth_e
        int 	InputGain;					//0~100
        int 	OutputGain; 				//0~100
    }u;
}audioParamSet_t;


//返回的摄像头显示图像数据结构
typedef struct{
    int resolution;  // 分辨率
    int brightness;  // 亮度
    int contrast;    // 对比度
    int saturation;  // 彩饱和度
    int sharpness;   // 锐利
    int frameRate;   // 帧率
    int bitRate;     // 码率
    int rotate;      // 图像镜像和返转0正常,1左右,2上下,3左右上下
    int ircut;       // ircut控制 0->自动，1->enable,2->关闭
    int mode;        // flicker
    
}cameraParams_t;

//设置运行参数数据结构
typedef struct tag_sysOprPolicy{
    unsigned int adcChkInterval;//adc检测最小周期，秒 >100
    unsigned int gpioChkInterval;//gpio输入检测最小周期，毫秒 >100
    
    unsigned int sysRunTime;//运行时长(秒) 0-->一直运行，n-->运行n秒
    
    unsigned char rcdPicEnable;//是否拍照 1-->是,非1不拍
    unsigned char rcdPicSize;//与码流对应 0-->720p,1-->次码流
    unsigned short rcdPicInterval;//拍照间隔(秒),0-->只拍一次
    
    unsigned char rcdAvEnable;//是否录像  1-->是,非1不录
    unsigned char rcdAvSize;//与码流对应 0-->720p,1-->次码流
    unsigned short rcdAvTime;//录像时长 0-->一直录，n-->录n秒
    
    unsigned char pushEnable;//0-->关闭
    unsigned char alarmEnable;//0-->关闭
    unsigned char wifiEnable;
    unsigned char osdEnable;//0-->自动,1-->关闭,2-->打开
    
    unsigned char powerMgrEnable;//0-->无,1-->CountDown,2--->schedule
    unsigned char powerMgrCountDown;//倒计时开机时长,分钟0~255
    unsigned char reserved2[2];
    unsigned int  powerMgrSchedule;//定时开机
}sysOprPolicy_t_EX,*pSysOprPolicy_t_EX;


typedef struct{
    int status;
    int totalSize;
    int usedSize;
    int badSize;
}SDINFO_t;

typedef struct lanSearchExtRet
{
    char mIP[16];
    char mDID[24];
    char mName[32];
}st_lanSearchExtRet;


typedef struct
{
    unsigned int      rcVideoWidth;
    unsigned int      rcVideoHeight;
    unsigned int      rcVideoRate;        // 帧率(25)
    unsigned int      rcVideoMaxBitrate;
    
    unsigned int      rcAudioSamplerate;
    unsigned int      rcAudioBitWidth;    // 8/16
    unsigned int      rcAudioMaxBitrate;
    unsigned int     rcAudioTrack;       // 1-单声道, 2-立体声
} mRecConfig_t;

typedef struct
{
    unsigned int      spMaxHour;
    unsigned int      spFullThreshold;
    unsigned int      spRecycle;
    unsigned int      spCleanData;
    unsigned int      spReserved;
} mStoragePolicy_t;

//设置SD卡参数的数据结构
typedef struct{
    mRecConfig_t	recConf;
    mStoragePolicy_t	storagePolicy;
}mAVRecPolicy_t;

//设置录像计划参数的数据结构
typedef struct tag_sdRecSchSet
{
    int record_schedule_sun_0;
    int record_schedule_sun_1;
    int record_schedule_sun_2;
    int record_schedule_mon_0;
    int record_schedule_mon_1;
    int record_schedule_mon_2;
    int record_schedule_tue_0;
    int record_schedule_tue_1;
    int record_schedule_tue_2;
    int record_schedule_wed_0;
    int record_schedule_wed_1;
    int record_schedule_wed_2;
    int record_schedule_thu_0;
    int record_schedule_thu_1;
    int record_schedule_thu_2;
    int record_schedule_fri_0;
    int record_schedule_fri_1;
    int record_schedule_fri_2;
    int record_schedule_sat_0;
    int record_schedule_sat_1;
    int record_schedule_sat_2;
}sdRecSchSet_t, *pSdRecSchSet_t;

//wifi设置的数据结构
typedef struct tag_wifiParam
{
    int enable;
    int wifiStatus;
    int mode;
    int channel;
    int authtype;
    int dhcp;
    char ssid[32];
    char psk[128];
    
    char ip[16];
    char mask[16];
    char gw[16];
    char dns1[16];
    char dns2[16];
}wifiParam_t,*pWifiParam_t;


typedef struct tag_wifiScanRet
{
    char ssid[64];
    char mac[8];
    int security;
    int dbm0;//«ø∂»÷µ
    int dbm1;//ª˘◊º
    int mode;
    int channel;
    
}wifiScanRet_t,*pWifiScanRet_t;

//设置时间的数据结构
typedef struct tag_datetimeParam
{
    int now;
    int tz;
    int ntp_enable;
    int xia_ling_shi_flag_status;
    char ntp_svr[64];
}datetimeParam_t,*pDatetimeParam_t;

//更改用户参数的数据结构
typedef struct tag_userSetting
{
    char user1[32];
    char pwd1[128];
    char user2[32];
    char pwd2[128];
    char user3[32];
    char pwd3[128];
}userSetting_t,*pUserSetting_t;


typedef struct tag_recFileSearchParam
{
    int starttime;
    int endtime;
}recFileSearchParam_t, *pRecFileSearchParam_t;


//获取视频回放列表的数据结构
typedef struct tag_STRU_SEARCH_SDCARD_RECORD_FILE
{
    int startPage;
    int pageNmb;
}sdRecSearchCondition_t, *PSTRU_SEARCH_SDCARD_RECORD_FILE;

//获取日志列表的数据结构
typedef struct tag_logSearchCondition{
    unsigned char searchType; // 0-->∞¥¿‡–Õ,1-->∞¥ ±º‰
    unsigned char mainType;
    unsigned char subType;
    unsigned char reserved;
    unsigned int startTime;
    unsigned int endTime;
}logSearchCondition_t;


typedef struct{
    unsigned char mainType;
    unsigned char subType;
    unsigned short	length;
    unsigned int timeStamp;
    unsigned char content[120];
}LogInfo_t;

//获取文件的数据结构
typedef struct tag_fileTransParam{
    int offset;
    char filename[128];
}fileTransParam_t;


typedef struct tag_xqFile{
    int type;
    unsigned int size;
    unsigned int  timeStamp;
    char name[64];
}xqFile_t;

//恢复运行出厂设置
typedef struct tag_recovery{
    int item_type;
}recovery_t;

typedef struct __CMDHEAD
{
    short 	startcode;
    short	cmd;
    short	len;
    short	version;
} cmdHead_t, *PCMDHEAD;


//计划
typedef struct  schedule
{
    int record_schedule_sun_0;
    int record_schedule_sun_1;
    int record_schedule_sun_2;
    int record_schedule_mon_0;
    int record_schedule_mon_1;
    int record_schedule_mon_2;
    int record_schedule_tue_0;
    int record_schedule_tue_1;
    int record_schedule_tue_2;
    int record_schedule_wed_0;
    int record_schedule_wed_1;
    int record_schedule_wed_2;
    int record_schedule_thu_0;
    int record_schedule_thu_1;
    int record_schedule_thu_2;
    int record_schedule_fri_0;
    int record_schedule_fri_1;
    int record_schedule_fri_2;
    int record_schedule_sat_0;
    int record_schedule_sat_1;
    int record_schedule_sat_2;
}schedule_t, *pSchedule_t;

//系统内置行为
typedef enum {
    BUILDIN_ACTION_NONE=0,//无关联行为
    BUILDIN_ACTION_SYSCFG_RECOVERY,//恢复缺省(出厂)设置
    BUILDIN_ACTION_DEFAULTCFG_CREATE,//创建出厂设置
    BUILDIN_ACTION_WIFI_RECOVERY,//恢复wifi缺省值
    BUILDIN_ACTION_WIFI_ONOFF,//控制wifi
    BUILDIN_ACTION_ISP_ONOFF,//ISP
    BUILDIN_ACTION_REC,//录像
    BUILDIN_ACTION_LIGHT,//打开灯板
    BUILDIN_ACTION_MSGP2P,//通过在线p2p发送告警
    BUILDIN_ACTION_MSGPUSH,//消息推送
    BUILDIN_ACTION_EMAIL,//邮件图片
    BUILDIN_ACTION_FTP,//发送FT图片
    BUILDIN_ACTION_DIGITAL_OUT,//输出报警
    BUILDIN_ACTION_ALARM_BELL,//警铃
    BUILDIN_ACTION_PRESET,//预置位
}buildinAction_e;

//gpio口select位图位置 两个字节，每位对应一个gpio口
typedef enum _gpioBmpPosition{
    GPIO_BMP_POS0=0,//ircut->gpio8
    GPIO_BMP_POS1,//ircut->gpio9
    GPIO_BMP_POS2,//GPIO55<--idle
    GPIO_BMP_POS3,//gpio12<--idle
    GPIO_BMP_POS4,//GPIO13<--idle
    GPIO_BMP_POS5,//ircut->灯板补光gpio6
    GPIO_BMP_POS6,//ircut->光敏检测gpio7
    GPIO_BMP_POS7,//GPIO14<--wifi
    GPIO_BMP_POS8,//reset复位键GPIO5
    GPIO_BMP_POS9,//功放GPIO47
    GPIO_BMP_POSa,//no define
    GPIO_BMP_POSb,//no define
    GPIO_BMP_POSc,//no define
    GPIO_BMP_POSd,//no define
    GPIO_BMP_POSe,//no define
    GPIO_BMP_POSf,//no define
}gpioBmpPosition_e;

//gpio 值
typedef enum GpioLevel{
    GPIO_LEVEL_LOW=0,
    GPIO_LEVEL_HIGH
}gpioLevel_e;

//gpio的IO方向定义
typedef enum tag_gpioDirection{
    GPIO_DIRECTION_IN=0,
    GPIO_DIRECTION_OUT
}gpioDirection_e;

//gpio口定义与当前值
typedef struct tag_gpioParam{
    unsigned int select;//gpio口位图gpioBmpPosition_e
    unsigned int direction;//gpio定义IO方向
    unsigned int value;//高低电平0或1
}gpioInfo_t;

//gpio口位图位置及相应值
typedef struct{
    int ioPos;//在位图中的位置
    int level;//值
}ioOutputSet_t;


//gpio接口值变化时关联行为CMD_INTERFACE_GPIOACTION_SET/Get
typedef struct{
    buildinAction_e action;//buildinAction_e
    int value;
}gpioCfg_t;


//输入报警 包括PIR,RF,IR,等其它任何行为
typedef struct
{
    int			bEnable;
    int			level;							//0-高 1-常闭
    int			duration;						//报警输出延长x秒关闭, 0-不关闭
    int			actionBmp;					//关联行为 buildinAction_e的位图
    schedule_t	schedule;
}ioInputAlarmParam_t;

//GPIO IN报警设置
typedef struct tag_gpioAction{
    int	ioPos;//gpio口位图gpioBmpPosition_e
    ioInputAlarmParam_t ioAlarmCfg;
}ioInputAlarmCfg_t;

typedef struct{
    int bEnable;//使能
    int sensitivity;//灵敏度
    int			actionBmp;					//关联行为 buildinAction_e的位图
    schedule_t	schedule;
}mdAlarmParam_t;

typedef mdAlarmParam_t mdAlarmCfg_t;

/*
 ADC模数接口
 采值CMD_INTERFACE_SADCVALUE_GET，配置上下限值关联行为CMD_INTERFACE_SADCCONFIG_SET
 */
typedef struct{
    int bEnable;//使能
    int topTrigValue;//触发上限值
    int bottomTrigValue;//触发下限值
    int topActionBmp;//buildinAction_e
    int bottomActionBmp;//buildinAction_e
    schedule_t	schedule;
}adcAlarmParam_t;

typedef struct
{
    int adcNo;//0--adc0,1--adc1(接了温感)
    adcAlarmParam_t adcCnf;//配置
}adcAlarmCfg_t;

//采样值
typedef struct
{
    int adcNo;
    unsigned int value;//值
}adcData_t;

//串口设置 CMD_INTERFACE_SERIALSETTING_SET/GET
typedef struct
{
    int dwBaudRate;     //!< 波特率(bps)(110,300,1200,2400,4800,9600,19200,38400,57600,115200,230400,460800,921600)
    int dataBit;        //!< 数据有几位(5,6,7,8)
    int stopBit;        //!< 停止位(1,2)
    int parity;         //!< 校验(0-无校验,1-奇校验,2-偶校验 3-标志 4-空格)
    int flowCtrl;       //!< 数据流控制(0-无,1-软流控,2-硬流控)
}serialParam_t;

//配置串口
typedef struct{
    int serialNo;//串口序号
    serialParam_t serialParam;
}serialCfg_t;

//串口透传数据CMD_INTERFACE_SERIALDATA_SET
typedef struct
{
    int len;
    char data[0];
}serialData_t;

typedef struct{
    int serialNo;
    serialData_t serialData;
}serialDataTrans_t;

#endif
