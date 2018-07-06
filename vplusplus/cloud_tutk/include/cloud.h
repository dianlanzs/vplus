
#ifndef __CLOUD_H__
#define __CLOUD_H__

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <pthread.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>




#ifdef __cplusplus
extern "C" {
#endif

#ifdef QT_ENV
#define CLOUD_PRINTF qDebug
#else
#define CLOUD_PRINTF printf
#endif


#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libavutil/avutil.h"
#include "libswscale/swscale.h"

//#define ALLOC_FRAME avcodec_alloc_frame
//#define FREE_FRAME avcodec_free_frame

#define ALLOC_FRAME av_frame_alloc
#define FREE_FRAME av_frame_free

/*
#include "libswresample/swresample.h"
#include "libavdevice/avdevice.h"
#include "libavutil/opt.h"
#include "libavutil/channel_layout.h"
#include "libavutil/parseutils.h"
#include "libavutil/samplefmt.h"
#include "libavutil/fifo.h"
#include "libavutil/intreadwrite.h"
#include "libavutil/dict.h"
#include "libavutil/mathematics.h"
#include "libavutil/pixdesc.h"
#include "libavutil/avstring.h"
#include "libavutil/imgutils.h"
#include "libavutil/timestamp.h"
#include "libavutil/bprint.h"
#include "libavutil/time.h"
#include "libavutil/threadmessage.h"
*/
typedef void* cloud_device_handle;
typedef int cloud_cam_handle;

typedef enum {
    CLOUD_DEVICE_STATE_UNKNOWN = 0,
    CLOUD_DEVICE_STATE_CONNECTED = 1,
    CLOUD_DEVICE_STATE_DISCONNECTED = -1 ,
    CLOUD_DEVICE_STATE_AUTHENTICATE_ERR = 3 ,
    CLOUD_DEVICE_STATE_UNINITILIZED = 4 ,
    CLOUD_DEVICE_STATE_OTHER_ERR = 5 ,
} cloud_device_state_t;

typedef enum {
    CLOUD_DEVICE_TYPE_INVALID = -1,
    CLOUD_DEVICE_TYPE_IPC = 0,
    CLOUD_DEVICE_TYPE_NVR = 1,
    CLOUD_DEVICE_TYPE_GW = 2,
} cloud_device_type_t;

typedef struct {
    char did[32]; // cloud_id
    char ip[16];
    char mac[16];
} local_device_info_t;

typedef struct {
    char camdid[32]; //rf_id
} device_cam_info_t;


typedef enum {
    CLOUD_CB_STATE = 1,
    CLOUD_CB_VIDEO = 2,
    CLOUD_CB_AUDIO = 3,
    CLOUD_CB_ADDCAM = 4,
    CLOUD_CB_ALARM = 5,
    CLOUD_CB_RECORD_LIST = 6,
    CLOUD_CB_VIDEO_BS = 7,
    CLOUD_CB_AUDIO_BS = 8,
    CLOUD_CB_CAM_CFG = 9,
    CLOUD_CB_CAM_INFO = 10,
    CLOUD_CB_CAM_SET_CFG = 11,

} CLOUD_CB_TYPE;

typedef struct cb_video_info_s {
    cloud_device_handle device;
    char camdid[32]; //rf_id
    AVFrame *pFrame;
    int org_width;
    int org_height;
    int width;
    int height;
    enum AVPixelFormat format;
    unsigned char *pix_buffer;
    unsigned int timestamp;
    unsigned int end_flag;
} cb_video_info_t;

typedef struct cb_audio_info_s {
    cloud_device_handle device;
    char camdid[32]; //rf_id
    AVFrame *pFrame;
    short *sample_buffer;
    int sample_length;
} cb_audio_info_t;

typedef struct cb_video_bs_info_s {
    cloud_device_handle device;
    char camdid[32]; //rf_id
    unsigned char *bs_data;
    int bs_size;
    unsigned int timestamp;
    unsigned int end_flag;
} cb_video_bs_info_t;

typedef struct cb_audio_bs_info_s {
    cloud_device_handle device;
    char camdid[32]; //rf_id
    unsigned char *bs_data;
    int bs_size;
} cb_audio_bs_info_t;


typedef enum {
    VIDEO_QUALITY_HIGH = 0,
    VIDEO_QUALITY_NORMAL,
    VIDEO_QUALITY_LOW,
} video_quality_t;

typedef enum {
    RECORD_TYPE_SCHED = 1,
    RECORD_TYPE_ALARM = 2,
    RECORD_TYPE_MANUL = 3,
    RECORD_TYPE_MAX = 4,
    RECORD_TYPE_ALL = 9,
} RECORD_TYPE;

typedef struct {
    char filename[64];
    unsigned int createtime;
    unsigned int timelength;
    unsigned int filelength;
    RECORD_TYPE recordtype;
    char camdid[32]; //rf_id
} rec_file_block;

typedef struct record_filelist_t {
    int num;
    rec_file_block *blocks;
} record_filelist_t;

typedef struct device_cam_cfg_s {
    char camdid[32]; //rf_id
    int pir_sensitivity;
    int battery_threshold;
    int rotate;
} device_cam_cfg_t;

typedef struct device_camera_info_s {
    char camdid[32]; //rf_id
    int batttery;
    int wifi;
    char verison[32];
} device_camera_info_t;

typedef struct device_cam_result_s {
    char camdid[32]; //rf_id
    int ret_val;
} device_cam_result_t;

typedef int rec_pb_handle;
//
//typedef int (*CLOUD_DEVICE_CALLBACK)(CLOUD_CB_TYPE type, void *param,void *context);

typedef int (*CLOUD_DEVICE_CALLBACK)(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context);
/*
if (type == CLOUD_CB_STATE) {
    cloud_device_state_t  state = *(cloud_device_state_t *)param;
} else if (type == CLOUD_CB_VIDEO) {
    cb_video_info_t *info = (cb_video_info_t *)param;
} else if (type == CLOUD_CB_AUDIO) {
    cb_audio_info_t *info = (cb_audio_info_t *)param;
} else if (type == CLOUD_CB_ADDCAM) {
    char *camdid = (char *)param;
} else if (type == CLOUD_CB_ALARM) {
    char *userdata = (char *)param;
} else if (type == CLOUD_CB_RECORD_LIST) {
    record_filelist_t *info = (record_filelist_t *)param;
} else if (type == CLOUD_CB_VIDEO_BS) {
    cb_video_bs_info_t *info = (cb_video_bs_info_t *)param;
} else if (type == CLOUD_CB_CAM_CFG) {
    device_cam_cfg_t *info = (device_cam_cfg_t *)param;
} else if (type == CLOUD_CB_CAM_INFO) {
    device_camera_info_t *info = (device_camera_info_t *)param;
} else if (type == CLOUD_CB_CAM_SET_CFG) {
    device_cam_result_t *info = (device_cam_result_t *)param;
}
*/

//云服务初始化。 首先调用，与是否连接设备无关
int cloud_init(void);
//云服务退出
int cloud_exit(void);
int cloud_set_appinfo(const char *appinfo);
//根据设备id创建一个设备句柄，之后对设备的操作必须带入这个句柄。
cloud_device_handle cloud_open_device(const char *did);
//销毁设备句柄
int cloud_close_device(cloud_device_handle handle);
//获取设备类型
cloud_device_type_t cloud_get_device_type(cloud_device_handle handle);
//主动获取设备状态
cloud_device_state_t cloud_get_device_status(cloud_device_handle handle);

int cloud_device_get_version(cloud_device_handle handle, const char *version);
//使用用户名和密码连接到设备，返回设备状态。
cloud_device_state_t cloud_connect_device(cloud_device_handle handle, const char* username,const char *password);
//重新连接到设备，返回设备状态。
cloud_device_state_t cloud_reconnect_device(cloud_device_handle handle);
//断开与设备连接
int cloud_disconnect_device(cloud_device_handle handle);
//获取当前设备下的camera数目
int cloud_device_get_cams(cloud_device_handle handle, int max_num, device_cam_info_t* info);

int cloud_device_probe_cam(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback, void* fn_context);
//往设备添加一个camera
int cloud_device_add_cam(cloud_device_handle handle, const char* cam_did);
//从设备删除一个camera
int cloud_device_del_cam(cloud_device_handle handle, const char* cam_did);
//局域网内搜索设备
int cloud_scan_local_device(local_device_info_t *device, int max_num, int time_second);
//播放设备camera视频
int cloud_device_play_video(cloud_device_handle handle,const char* cam_did);
//停止播放设备camera视频
int cloud_device_stop_video(cloud_device_handle handle,const char* cam_did);
//播放设备camera音频
int cloud_device_play_audio(cloud_device_handle handle,const char* cam_did);
//播放设备camera音频
int cloud_device_stop_audio(cloud_device_handle handle,const char* cam_did);
//打开设备camera声音输出
int cloud_device_speaker_enable(cloud_device_handle handle,const char* cam_did);
//关闭设备camera声音输出
int cloud_device_speaker_disable(cloud_device_handle handle,const char* cam_did);
//发送手机采集的pcm数据
int cloud_device_speaker_data(cloud_device_handle handle,const char* cam_did,unsigned char* data, int size);
//设置设备状态回调函数
int cloud_set_status_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context);
//设置设备av数据（解码后）显示回调函数
int cloud_set_data_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context);
int cloud_set_event_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context);
int cloud_set_pblist_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context);

int cloud_device_cam_set_display(cloud_device_handle handle,const char* cam_did, enum AVPixelFormat format,int width, int height);


//其它命令
//获取设备camera质量
int cloud_device_cam_get_quality(cloud_device_handle handle,const char* cam_did, video_quality_t quality);
//配置设备camera质量
int cloud_device_cam_set_quality(cloud_device_handle handle,const char* cam_did, video_quality_t quality);

int cloud_device_cam_get_battery(cloud_device_handle handle,const char* cam_did);
int cloud_device_cam_get_signal(cloud_device_handle handle,const char* cam_did);




//int cloud_device_cam_list_files(cloud_device_handle handle,const char* cam_did, int start_time,int end_time,RECORD_TYPE recordtype,int *block_num, rec_file_block **blocks);
int cloud_device_cam_list_files(cloud_device_handle handle,const char* cam_did, int start_time,int end_time,RECORD_TYPE recordtype);
int cloud_device_cam_pb_play_file(cloud_device_handle handle,const char* cam_did, const char *filename);
int cloud_device_cam_pb_play_time(cloud_device_handle handle,const char* cam_did, int time);
int cloud_device_cam_pb_stop(cloud_device_handle handle,const char* cam_did);
int cloud_device_cam_pb_seek_file(cloud_device_handle handle,const char* cam_did, int offset);
int cloud_device_cam_pb_pause(cloud_device_handle handle,const char* cam_did);
int cloud_device_cam_pb_resume(cloud_device_handle handle,const char* cam_did);

int cloud_device_cam_get_info(cloud_device_handle handle,const char* cam_did);
int cloud_device_cam_set_cfg(cloud_device_handle handle,const char* cam_did, device_cam_cfg_t *val);
int cloud_device_cam_get_cfg(cloud_device_handle handle,const char* cam_did);

int cloud_notify_network_changed(void);

#ifdef __cplusplus
}
#endif

#endif // __CLOUD_H__
