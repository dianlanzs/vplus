#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

#include "cloud.h"

#include "tutk_inc/IOTCAPIs.h"
#include "tutk_inc/AVAPIs.h"
#include "AVFRAMEINFO.h"
#include "AVIOCTRLDEFs.h"


#define DEVICE_CAM_NUM_MAX 8


#define ut_vmutex_t                     pthread_mutex_t

#define ut_vmutex_create(_mutex, _name) pthread_mutex_init(&(_mutex), NULL)
#define ut_vmutex_create_recur(_mutex, _name)   \
                                        do { \
                                            pthread_mutexattr_t ma;     \
                                            pthread_mutexattr_init(&ma);        \
                                            pthread_mutexattr_settype(&ma, PTHREAD_MUTEX_RECURSIVE);     \
                                            pthread_mutex_init(&(_mutex), &ma); } while(0)


#define ut_vmutex_destroy(_mutex)       pthread_mutex_destroy(&(_mutex))
#define ut_vmutex_lock(_mutex)          pthread_mutex_lock(&(_mutex))
#define ut_vmutex_trylock(_mutex)       pthread_mutex_trylock(&(_mutex))
#define ut_vmutex_unlock(_mutex)        pthread_mutex_unlock(&(_mutex))

struct cloud_cmd_s;

typedef struct {
    struct cloud_cmd_s* m_first;
    struct cloud_cmd_s* m_last;
    ut_vmutex_t         m_mutex;
    int m_count;
} cloud_cmd_queue_t;

typedef struct cmd_msg_s {
    unsigned int data[4];
    void *ext;
} cmd_msg_t;
typedef struct cloud_cmd_s {
    struct cloud_cmd_s* m_prev;
    struct cloud_cmd_s* m_next;
    cmd_msg_t m_msg;
} cloud_cmd_t;


typedef enum {
    DEVICE_CONNECT = (1<<0),
    DEVICE_DISCONNECT = (1<<1),
    PLAY_VIDEO = (1<<2),
    STOP_VIDEO = (1<<3),
    PLAY_AUDIO = (1<<4),
    STOP_AUDIO = (1<<5),
    PLAY_SPEAK = (1<<6),
    STOP_SPEAK = (1<<7),
    DEVICE_PBLIST  = (1<<8),
    DEVICE_PBCTRL  = (1<<9),
    DEVICE_PROBECAM = (1<<10),
    DEVICE_ADDCAM  = (1<<11),
    DEVICE_DELCAM  = (1<<12),
    DEVICE_CAM_SETCFG  = (1<<13),
    DEVICE_CAM_GETCFG  = (1<<14),
    DEVICE_CAM_GETINFO  = (1<<15),
    DEVICE_FORGET = (1<<16),

} CLOUD_DEVICE_CMD;


typedef struct cam_info_s {
    int valid;
    /*
    AVCodecContext *video_codec_ctx;
    AVPacket packet;
    AVFrame *pFrame_;
    int frameCount;

    int pic_width;
    int pic_height;
    int dis_width;
    int dis_height;
    enum AVPixelFormat dis_format;
    AVFrame *pFrameOut;
    unsigned char *dis_buffer;
    struct SwsContext *img_convert_ctx;

	int cnt;
	int fpsCnt;
	int bps;
	int lostCnt;
	*/

    record_filelist_t rec_info;

	device_cam_info_t cam_info;

	char version[32];
	int rotate;
	int battery_threshold;
	int pir_sensitivity;


} cam_info_t;

typedef struct {
    char UID[64];
    char username[32];
    char password[32];
    char version[32];
    int exit;


    pthread_t device_ID;
    pthread_t ThreadVideo_ID ;
    pthread_t ThreadAudio_ID;
    pthread_t ThreadSpeaker_ID;

    pthread_mutex_t lock;
    pthread_cond_t cond;

    CLOUD_DEVICE_CMD cmd;

    int videc_connect_err;
    int audio_connect_err;

    int SID;
    int speakerCh;
    int avIndex;

    CLOUD_DEVICE_CALLBACK _callback;
    void* _context;

    CLOUD_DEVICE_CALLBACK _data_callback;
    void* _data_context;

    CLOUD_DEVICE_CALLBACK _event_callback;
    void* _event_context;

    CLOUD_DEVICE_CALLBACK _probecam_callback;
    void* _probecam_context;

    CLOUD_DEVICE_CALLBACK _pblist_callback;
    void* _pblist_context;

    CLOUD_DEVICE_CMD cam_sta[DEVICE_CAM_NUM_MAX];
    cam_info_t cam[DEVICE_CAM_NUM_MAX];
    int cam_num;
    int cam_play_num;

    int audio_cam_id;
    int speak_cam_id;

    int audio_stopping;
    int audio_stopped;
    int speak_stopping;
    int speak_stopped;

    int seeking;
    int paused;

    AVCodecContext *audio_codec_ctx;
    AVPacket audio_packet;
    AVFrame *audio_pFrame_;
    //short audio_sample[1024];

    AVCodecContext *video_codec_ctx;
    AVPacket video_packet;
    AVFrame *video_pFrame_;
	int cnt;
	int fpsCnt;
	int bps;
	int lostCnt;

    cloud_device_state_t  state;

    cloud_cmd_queue_t* msgq;
    unsigned char play_seq;
    unsigned int play_timestamp_base;
} cloud_device_t;

static char g_appinfo[APP_ID_LENGTH];
static int g_video_bsout = 0;
static int g_audio_bsout = 0;

static void *thread_device(void *arg);
static void *thread_ReceiveVideo(void *arg);
static void *thread_ReceiveAudio(void *arg);
static void *thread_SendAudio(void *arg);
static int device_decoder_reset(cloud_device_t *device);
static int device_cam_init(cloud_device_t *device,int camid,char *camdid);
static int device_cam_deinit(cloud_device_t *device,int camid);
static void cam_video_dec(cloud_device_t *device,cam_info_t *cam , char* buf, int size,unsigned int timestamp);
static void device_video_dec(cloud_device_t *device,cam_info_t *cam ,char* buf, int size,unsigned int timestamp);

static int device_audio_init(cloud_device_t *device);
static int device_audio_deinit(cloud_device_t *device);
static void device_audio_dec(cloud_device_t *device, char* buf, int size);

static int voice_data_get(unsigned char** addr,int max_size);
static int voice_data_put(unsigned char* addr,int size);
static void voice_data_clear();
static int find_cam(cloud_device_t *device,const char* camdid);

static cloud_cmd_queue_t* ut_msgq_create();
static int ut_msgq_destroy(cloud_cmd_queue_t *p_msgq_ctx);
static int cloud_cmd_put(cloud_cmd_queue_t *p_msgq_ctx,cloud_cmd_t *p_msg_node);
static cloud_cmd_t* cloud_cmd_get(cloud_cmd_queue_t *p_msgq_ctx);
static int cloud_cmd_clear(cloud_cmd_queue_t *p_msgq_ctx);
static cloud_cmd_t* new_cmd(unsigned int cmd_type, int size);
static void free_cmd(cloud_cmd_t *cmd);




static AVCodec *videoCodec;
static AVCodec *audioCodec;




#define DEVICE_STATE_SET(device,newstate) do { \
    printf("device %p state => %d\n",device,newstate); \
    pthread_mutex_lock(&device->lock); \
    device->state = newstate; \
    pthread_mutex_unlock(&device->lock); \
}while(0)

#define DEVICE_NUM_MAX  64
static cloud_device_t *g_device_list[DEVICE_NUM_MAX];
static cloud_device_t *alloc_device(const char *did)
{
    int free_id = -1;
    int i;
    for (i=0;i<DEVICE_NUM_MAX;i++) {
        if (g_device_list[i] == NULL) {
            if (free_id < 0) {
                free_id = i;
            }
        } else {
            if (strcmp(g_device_list[i]->UID,did) == 0) {
                CLOUD_PRINTF("device is already allocated !\n");
                return g_device_list[i];
            }
        }
    }
    if (free_id == -1) {
        CLOUD_PRINTF("device num up to DEVICE_NUM_MAX\n");
        return NULL;
    }
    cloud_device_t *device = (cloud_device_t *)malloc(sizeof(cloud_device_t));
    if (device == NULL) {
        return NULL;
    }
    memset(device,0,sizeof(cloud_device_t));
    g_device_list[free_id] = device;
    printf("alloc_device %d = %p\n",i,g_device_list[i]);
    return device;
}
static void free_device(cloud_device_t *device)
{
    int i;
    for (i=0;i<DEVICE_NUM_MAX;i++) {
        if (g_device_list[i] == device) {
            free(device);
            g_device_list[i] = NULL;
            printf("free_device %d = %p\n",i,g_device_list[i]);

            return ;
        }
    }
    if (i == DEVICE_NUM_MAX) {
        CLOUD_PRINTF("device %p is not found in DEVICE_NUM_MAX\n",device);
        return;
    }
}
static cloud_device_t *find_device(const char *did)
{
    int i;
    for (i=0;i<DEVICE_NUM_MAX;i++) {
        if (g_device_list[i]) {
            if (strcmp(g_device_list[i]->UID,did) == 0) {
                return g_device_list[i];
            }
        }
    }
    CLOUD_PRINTF("device %s is not found in DEVICE_NUM_MAX\n",did);
    return NULL;
}

int cloud_init()
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
	int ret = IOTC_Initialize2(0);
	//CLOUD_PRINTF("IOTC_Initialize() ret = %d\n", ret);
	if(ret != IOTC_ER_NoERROR)
	{
		CLOUD_PRINTF("IOTC_Initialize2 err...!!\n");
		return -1;
	}

	// alloc 3 sessions for video and two-way audio
	avInitialize(32);
	unsigned int iotcVer;
	IOTC_Get_Version(&iotcVer);
	int avVer = avGetAVApiVer();
	unsigned char *p = (unsigned char *)&iotcVer;
	unsigned char *p2 = (unsigned char *)&avVer;
	char szIOTCVer[16], szAVVer[16];
	sprintf(szIOTCVer, "%d.%d.%d.%d", p[3], p[2], p[1], p[0]);
	sprintf(szAVVer, "%d.%d.%d.%d", p2[3], p2[2], p2[1], p2[0]);
	CLOUD_PRINTF("IOTCAPI version[%s] AVAPI version[%s]\n", szIOTCVer, szAVVer);

	av_register_all();
	/* find the video encoder */
	videoCodec = avcodec_find_decoder(AV_CODEC_ID_H264);//得到264的解码器类
	if(!videoCodec)
	{
		CLOUD_PRINTF("avcodec_find_decoder error\n");
        avDeInitialize();
        IOTC_DeInitialize();
		return -1;
	}
	audioCodec = avcodec_find_decoder(AV_CODEC_ID_PCM_MULAW);
	if(!audioCodec)
	{
		CLOUD_PRINTF("avcodec_find_decoder error\n");
        avDeInitialize();
        IOTC_DeInitialize();
		return -1;
	}
    int i;
    for (i=0;i<DEVICE_NUM_MAX;i++) {
        g_device_list[i] = NULL;
    }
    return 0;
}

int cloud_exit(void)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
	avDeInitialize();
	IOTC_DeInitialize();


    CLOUD_PRINTF("cloud_exited!\n");
    return 0;
}
int cloud_set_appinfo(const char *appinfo)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
	strcpy(g_appinfo,appinfo);
	CLOUD_PRINTF("appinfo:[%s]\n",appinfo);
	return 0;
}
int cloud_notify_network_changed(void)
{
    printf("cloud_notify_network_changed\n");
    cloud_device_t *device;
    int i;
    for (i=0;i<DEVICE_NUM_MAX;i++) {

        if (g_device_list[i] == NULL) {
            continue;
        }
        printf("g_device_list[%d] = %p\n ",i,g_device_list[i]);
        device = g_device_list[i];
        pthread_mutex_lock(&device->lock);
        cloud_cmd_t *cmd = new_cmd(DEVICE_DISCONNECT,0);
        if (cmd == NULL) {
            CLOUD_PRINTF("err:new cmd fail!\n");
            pthread_mutex_unlock(&device->lock);
            continue;
        }
        cloud_cmd_put(device->msgq,cmd);
        pthread_mutex_unlock(&device->lock);
    }
    return 0;
}
cloud_device_handle cloud_open_device(const char *did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = alloc_device(did);//(cloud_device_t *)malloc(sizeof(cloud_device_t));
    if (device == NULL) {
        return (cloud_device_handle)NULL;
    }
    memset(device,0,sizeof(cloud_device_t));
    device->exit = 0;
    strcpy(device->UID, did);
    device->SID = -1;
    device->avIndex = -1;
    device->cam_play_num = 0;
    device->audio_cam_id = -1;
    device->audio_stopping = 0;
    device->audio_stopped = 0;
    device->speak_cam_id = -1;
    device->speak_stopping = 0;
    device->speak_stopped = 0;
    DEVICE_STATE_SET(device,CLOUD_DEVICE_STATE_DISCONNECTED);

    pthread_mutexattr_t ma;
    pthread_mutexattr_init(&ma);
    pthread_mutexattr_settype(&ma, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&device->lock,&ma);

    pthread_cond_init(&device->cond,NULL);
    device->msgq = ut_msgq_create();

    int ret;
    if ( (ret=pthread_create(&device->device_ID, NULL, &thread_device, (void *)device)) )
    {
        CLOUD_PRINTF("cloud_open_device, thread_device failed\n");
        free(device);
        return NULL;
    }

    if ( (ret=pthread_create(&device->ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)device)) )
    {
        CLOUD_PRINTF("cloud_open_device,Create Video Receive thread failed\n");
        ut_msgq_destroy(device->msgq);
        pthread_join(device->device_ID,NULL);
        free(device);

        return NULL;
    }
    if ( (ret=pthread_create(&device->ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)device)) )
    {
        CLOUD_PRINTF("cloud_open_device,Create Audio Receive thread failed\n");
        ut_msgq_destroy(device->msgq);
        pthread_join(device->device_ID,NULL);
        pthread_join(device->ThreadVideo_ID,NULL);
        free(device);

        return NULL;
    }
    /*
    if ( (ret=pthread_create(&device->ThreadSpeaker_ID, NULL, &thread_SendAudio, (void *)device)) )
    {
        CLOUD_PRINTF("Create Audio send thread failed\n");
        pthread_join(device->device_ID,NULL);
        pthread_join(device->ThreadVideo_ID,NULL);
        pthread_join(device->ThreadAudio_ID,NULL);
        free(device);

        return NULL;
    }
    */
	CLOUD_PRINTF("__%s__%d__:%p\n",__FUNCTION__,__LINE__,device);

    return (cloud_device_handle)device;
}
int cloud_close_device(cloud_device_handle handle)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    device->exit = 1;
    pthread_join(device->ThreadVideo_ID,NULL);
    pthread_join(device->ThreadAudio_ID,NULL);
    //pthread_join(device->ThreadSpeaker_ID,NULL);
    pthread_join(device->device_ID,NULL);

    pthread_mutex_destroy(&device->lock);
    pthread_cond_destroy(&device->cond);
    ut_msgq_destroy(device->msgq);

    free_device(device);//free(device);
	return 0;
}

cloud_device_type_t cloud_get_device_type(cloud_device_handle handle)
{
    return CLOUD_DEVICE_TYPE_GW;
}

cloud_device_state_t cloud_get_device_status(cloud_device_handle handle)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    return device->state;
}

cloud_device_state_t cloud_connect_device(cloud_device_handle handle, const char* username,const char *password)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;
    pthread_mutex_lock(&device->lock);

    strcpy(device->username,username);
    strcpy(device->password,password);


    cloud_cmd_t *cmd = new_cmd(DEVICE_CONNECT,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cloud_cmd_put(device->msgq,cmd);


    pthread_mutex_unlock(&device->lock);

    return device->state;
}

cloud_device_state_t cloud_reconnect_device(cloud_device_handle handle)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    return cloud_connect_device(handle,device->username,device->password);
}

int cloud_disconnect_device(cloud_device_handle handle)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    cloud_cmd_t *cmd = new_cmd(DEVICE_FORGET,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cloud_cmd_put(device->msgq,cmd);

    cmd = new_cmd(DEVICE_DISCONNECT,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);

	return 0;
}

int cloud_device_get_version(cloud_device_handle handle, const char *version)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);

    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    strcpy(version,device->version);
    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_probe_cam(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback, void* fn_context)
{
    cloud_device_t *device = (cloud_device_t *)handle;

	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }

    device->_probecam_callback = fn_callback;
    device->_probecam_context = fn_context;


    cloud_cmd_t *cmd = new_cmd(DEVICE_PROBECAM,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cloud_cmd_put(device->msgq,cmd);

    //device->cmd |= DEVICE_PROBECAM;

    pthread_mutex_unlock(&device->lock);
    return 0;
}


int cloud_device_add_cam(cloud_device_handle handle, const char* cam_did)
{
    cloud_device_t *device = (cloud_device_t *)handle;

	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }

    int index = -1;
    int i;
    for(i=0;i<DEVICE_CAM_NUM_MAX;i++) {
        if (device->cam[i].valid == 0) {
            index = i;
            break;
        }
    }
    if (index < 0) {
        CLOUD_PRINTF("err:cam id is full!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }

    device_cam_init(device,index,cam_did);
    device->cam_sta[index] = 0;
    device->cam_num ++;

    cloud_cmd_t *cmd = new_cmd(DEVICE_ADDCAM,sizeof(SMsgAVIoctrlCamera));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlCamera* camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

    camctrl->channel = index;
    strcpy(camctrl->szCameraID, cam_did);

    cloud_cmd_put(device->msgq,cmd);

    //device->cmd |= DEVICE_ADDCAM;


    pthread_mutex_unlock(&device->lock);
    return 0 ;
}

int cloud_device_del_cam(cloud_device_handle handle, const char* cam_did)
{
    cloud_device_t *device = (cloud_device_t *)handle;

	CLOUD_PRINTF("__%s__: cam_did %s\n",__FUNCTION__,cam_did);
    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    if (cam_handle == 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("master cam cannot be deleted!\n");
        return -1;
    }

    device_cam_deinit(device,cam_handle);
    device->cam_num --;

    cloud_cmd_t *cmd = new_cmd(DEVICE_DELCAM,sizeof(SMsgAVIoctrlCamera));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlCamera* camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

    camctrl->channel = cam_handle;

    cloud_cmd_put(device->msgq,cmd);


    //device->cmd |= DEVICE_DELCAM;


    pthread_mutex_unlock(&device->lock);

	return 0;
}


int cloud_device_get_cams(cloud_device_handle handle, int max_num, device_cam_info_t* info)
{
    cloud_device_t *device = (cloud_device_t *)handle;

	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return 0;
    }
    int num = 0;//(device->cam_num > max_num)?max_num;device->cam_num;
    int i;
    for(i=0;i<DEVICE_CAM_NUM_MAX && num<max_num;i++) {
        if (device->cam[i].valid == 1) {
            CLOUD_PRINTF("index %d: valid , camdid %s\n",i,device->cam[i].cam_info.camdid);
            strcpy(info[num].camdid,device->cam[i].cam_info.camdid);
            num ++;
        }
    }
    //pthread_cond_wait(&device->cond,&device->lock);
    pthread_mutex_unlock(&device->lock);

	return num;
}

int cloud_device_play_video(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }

    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }

    cloud_cmd_t *cmd = new_cmd(PLAY_VIDEO,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    cmd->m_msg.data[1] = cam_handle;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_stop_video(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }

    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(STOP_VIDEO,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cmd->m_msg.data[1] = cam_handle;
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_play_audio(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;


    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(PLAY_AUDIO,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    cmd->m_msg.data[1] = cam_handle;
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_stop_audio(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;


    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(STOP_AUDIO,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cmd->m_msg.data[1] = cam_handle;
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_speaker_enable(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(PLAY_SPEAK,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cmd->m_msg.data[1] = cam_handle;
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_speaker_disable(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(STOP_SPEAK,0);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    cmd->m_msg.data[1] = cam_handle;
    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_speaker_data(cloud_device_handle handle,const char* cam_did,unsigned char* data, int size)
{
    cloud_device_t *device = (cloud_device_t *)handle;

    if (device->speak_cam_id < 0) {
        return -1;
    }
    voice_data_put(data,size);
    return 0;
}

int cloud_device_cam_get_battery(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    return 50;
}

int cloud_device_cam_get_signal(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    return 50;
}


int cloud_device_cam_get_info(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(DEVICE_CAM_GETINFO,sizeof(SMsgAVIoctrlCamera));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlCamera *cfg = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;
    cfg->channel = cam_handle;

    cloud_cmd_put(device->msgq,cmd);
    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_cam_set_cfg(cloud_device_handle handle,const char* cam_did, device_cam_cfg_t *val)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(DEVICE_CAM_SETCFG,sizeof(SMsgAVIoctrlCamCfg));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlCamCfg *cfg = (SMsgAVIoctrlCamCfg *)cmd->m_msg.ext;
    cfg->battery_threshold = val->battery_threshold;
    cfg->cam_rotate = val->rotate;
    cfg->pir_sensitivity = val->pir_sensitivity;
    cfg->channel = cam_handle;
    cloud_cmd_put(device->msgq,cmd);
    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_cam_get_cfg(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);
    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(DEVICE_CAM_GETCFG,sizeof(SMsgAVIoctrlCamera));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlCamera *cfg = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;
    cfg->channel = cam_handle;

    cloud_cmd_put(device->msgq,cmd);
    pthread_mutex_unlock(&device->lock);
    return 0;
}

int cloud_device_cam_list_files(cloud_device_handle handle,const char* cam_did, int start_time,int end_time,RECORD_TYPE recordtype)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }

    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        CLOUD_PRINTF("device cam not find, list all cams!\n");
        cam_handle = -1;
    }

    cloud_cmd_t *cmd = new_cmd(DEVICE_PBLIST,sizeof(SMsgAVIoctrlListYGEventReq));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    SMsgAVIoctrlListYGEventReq* pblist = (SMsgAVIoctrlListYGEventReq *)cmd->m_msg.ext;

    pblist->channel = cam_handle;
    pblist->type = recordtype;
    pblist->tmbegin = start_time;
    pblist->tmend = end_time;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);


    return 0;

}

int cloud_device_cam_pb_play_file(cloud_device_handle handle,const char* cam_did, const char *filename)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }

    cloud_cmd_t *cmd = new_cmd(DEVICE_PBCTRL,sizeof(SMsgAVIoctrlPlayRecord)+64);
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    device->paused = 0;
    SMsgAVIoctrlPlayRecord* ioMsg = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

    ioMsg->channel = cam_handle;
    ioMsg->command = AVIOCTRL_RECORD_PLAY_START;
    ioMsg->reserved[0] = 0x79;
    ioMsg->reserved[1] = 0x67;
    char *fname = (char *)ioMsg + sizeof(SMsgAVIoctrlPlayRecord);
    strcpy(fname,filename);
    printf("filename = %s, fname = %s\n",filename,fname);

    cloud_cmd_put(device->msgq,cmd);


    pthread_mutex_unlock(&device->lock);


    return 0;

}

int cloud_device_cam_pb_play_time(cloud_device_handle handle,const char* cam_did, int time)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    return 0;

}

int cloud_device_cam_pb_stop(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }

    cloud_cmd_t *cmd = new_cmd(DEVICE_PBCTRL,sizeof(SMsgAVIoctrlPlayRecord));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    device->paused = 0;
    SMsgAVIoctrlPlayRecord* ioMsg = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

    ioMsg->channel = cam_handle;
    ioMsg->command = AVIOCTRL_RECORD_PLAY_STOP;
    ioMsg->reserved[0] = 0x79;
    ioMsg->reserved[1] = 0x67;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);


    return 0;

}
int cloud_device_cam_pb_pause(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    if (device->paused) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device already paused!\n");
        return -1;
    }

    cloud_cmd_t *cmd = new_cmd(DEVICE_PBCTRL,sizeof(SMsgAVIoctrlPlayRecord));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    device->paused = 1;
    SMsgAVIoctrlPlayRecord* ioMsg = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

    ioMsg->channel = cam_handle;
    ioMsg->command = AVIOCTRL_RECORD_PLAY_PAUSE;
    ioMsg->reserved[0] = 0x79;
    ioMsg->reserved[1] = 0x67;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);

    return 0;

}

int cloud_device_cam_pb_resume(cloud_device_handle handle,const char* cam_did)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }
    if (device->paused == 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device already resumed!\n");
        return -1;
    }
    cloud_cmd_t *cmd = new_cmd(DEVICE_PBCTRL,sizeof(SMsgAVIoctrlPlayRecord));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 0;
    device->paused = 0;

    SMsgAVIoctrlPlayRecord* ioMsg = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

    ioMsg->channel = cam_handle;
    ioMsg->command = AVIOCTRL_RECORD_PLAY_PAUSE;//same as resume
    ioMsg->reserved[0] = 0x79;
    ioMsg->reserved[1] = 0x67;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);

    return 0;

}

int cloud_device_cam_pb_seek_file(cloud_device_handle handle,const char* cam_did, int offset)
{
	CLOUD_PRINTF("__%s__\n",__FUNCTION__);
    cloud_device_t *device = (cloud_device_t *)handle;

    pthread_mutex_lock(&device->lock);

    if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device->state != CLOUD_DEVICE_STATE_CONNECTED\n");
        return -1;
    }
    int cam_handle = find_cam(device,cam_did);
    if (cam_handle < 0) {
        pthread_mutex_unlock(&device->lock);
        CLOUD_PRINTF("device cam not valid!\n");
        return -1;
    }


    cloud_cmd_t *cmd = new_cmd(DEVICE_PBCTRL,sizeof(SMsgAVIoctrlPlayRecord));
    if (cmd == NULL) {
        CLOUD_PRINTF("err:new cmd fail!\n");
        pthread_mutex_unlock(&device->lock);
		return -1;
    }
    device->seeking = 1;

    SMsgAVIoctrlPlayRecord* ioMsg = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

    ioMsg->channel = cam_handle;
    ioMsg->command = AVIOCTRL_RECORD_PLAY_SEEKTIME;
    ioMsg->Param = offset;
    ioMsg->reserved[0] = 0x79;
    ioMsg->reserved[1] = 0x67;

    cloud_cmd_put(device->msgq,cmd);

    pthread_mutex_unlock(&device->lock);


    return 0;

}

int cloud_set_video_bsout(int enable)
{
    g_video_bsout = enable;
    return 0;
}
int cloud_set_audio_bsout(int enable)
{
    g_audio_bsout = enable;
    return 0;
}

int cloud_set_status_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    pthread_mutex_lock(&device->lock);
    device->_callback = fn_callback;
    device->_context = context;
    pthread_mutex_unlock(&device->lock);
    return 0;
}
int cloud_set_data_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    pthread_mutex_lock(&device->lock);
    device->_data_callback = fn_callback;
    device->_data_context = context;
    pthread_mutex_unlock(&device->lock);
    return 0;
}
int cloud_set_event_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    pthread_mutex_lock(&device->lock);
    device->_event_callback = fn_callback;
    device->_event_context = context;
    pthread_mutex_unlock(&device->lock);
    return 0;
}
int cloud_set_pblist_callback(cloud_device_handle handle, CLOUD_DEVICE_CALLBACK fn_callback,void* context)
{
    cloud_device_t *device = (cloud_device_t *)handle;
    pthread_mutex_lock(&device->lock);
    device->_pblist_callback = fn_callback;
    device->_pblist_context = context;
    pthread_mutex_unlock(&device->lock);
    return 0;
}
/**************************************************************************************************************************************************************/
/**************************************************************************************************************************************************************/
/**************************************************************************************************************************************************************/


#define MAX_SIZE_IOCTRL_BUF		2048

typedef struct {
    char filename[64];
    unsigned int createtime;
    unsigned int timelength;
    unsigned int filelength;
    RECORD_TYPE recordtype;
} rec_event_block;

static void process_recv_cmd(cloud_device_t *device, unsigned int ioType,char *ioCtrlBuf)
{
    if (ioType == IOTYPE_USER_DEVICE_PROBECAM) {

        SMsgAVIoctrlCamera *addcam_param = (SMsgAVIoctrlCamera *)ioCtrlBuf;

        pthread_mutex_lock(&device->lock);

        if (addcam_param->szCameraID[0] == 0) {
            CLOUD_PRINTF("add failed: szCameraID = 0\n");
            pthread_mutex_unlock(&device->lock);
            return;
        }

        //pthread_cond_wait(&device->cond,&device->lock);
        pthread_mutex_unlock(&device->lock);

        if (device->_probecam_callback) {

            device->_probecam_callback(device,CLOUD_CB_ADDCAM,addcam_param->szCameraID,device->_probecam_context);
        }
    } else if (ioType == IOTYPE_USER_IPCAM_SENDUSERDATA) {

        SMsgAVIoctrlUserData *userdata = (SMsgAVIoctrlUserData *)ioCtrlBuf;

        if (device->_event_callback) {

            device->_event_callback(device,CLOUD_CB_ALARM,userdata->userdata,device->_data_context);
        }

    } else if (ioType == IOTYPE_USER_IPCAM_LIST_YGEVENT_RESP) {

        SMsgAVIoctrlListYGEventResp *gEventListRes = (SMsgAVIoctrlListYGEventResp *)ioCtrlBuf;



        int cam_handle = gEventListRes->channel;
        cam_info_t *cam;
        if (device->cam[cam_handle].valid == 0) {
            printf("IOTYPE_USER_IPCAM_LISTEVENT_RESP: channel not exist!\n");
            return;
        }
        cam = &device->cam[cam_handle];
        if (gEventListRes->event_start == 0) {
            if (cam->rec_info.blocks) {
                free(cam->rec_info.blocks);
            }
            cam->rec_info.num = gEventListRes->event_total;
            cam->rec_info.blocks = malloc(cam->rec_info.num*sizeof(rec_file_block));
            if (cam->rec_info.blocks == NULL) {
                cam->rec_info.num = 0;
                printf("malloc rec_info.blocks failed\n");
                return;
            }
            memset(cam->rec_info.blocks,0,cam->rec_info.num*sizeof(rec_file_block));
        }
        printf("event_total %d, event_start %d, event_count %d\n",gEventListRes->event_total,gEventListRes->event_start,gEventListRes->event_count);
        int i;
        rec_event_block *eblock = (rec_event_block *)&gEventListRes->event;
        rec_file_block *rblock = cam->rec_info.blocks;
        rblock += gEventListRes->event_start;

        for (i=0;i<gEventListRes->event_count;i++) {

            memcpy(rblock,eblock,sizeof(rec_event_block));
            //printf("rblock %d: %p, %s - %d\n",i+gEventListRes->event_start, rblock, rblock->filename,rblock->createtime);
            //printf("eblock %d: %x :%s\n",i, eblock, eblock->filename);
            strcpy(rblock->camdid, cam->cam_info.camdid);
            eblock ++;
            rblock ++;
        }

        //memcpy(&cam->rec_info.blocks[gEventListRes->event_start],&gEventListRes->event,gEventListRes->event_count*sizeof(rec_file_block));

        if (device->_pblist_callback && gEventListRes->event_start+gEventListRes->event_count >= gEventListRes->event_total) {

            device->_pblist_callback(device,CLOUD_CB_RECORD_LIST,&cam->rec_info,device->_pblist_context);
        }
    } else if (ioType == IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL_RESP) {
        SMsgAVIoctrlPlayRecordResp *resp = (SMsgAVIoctrlPlayRecordResp *)ioCtrlBuf;
        if (resp->command == AVIOCTRL_RECORD_PLAY_SEEKTIME) {
            if (device->seeking == 1) {
                device->seeking = 0;
            }
            printf("seek done!!!\n");
        } else if (resp->command == AVIOCTRL_RECORD_PLAY_END) {
            printf("play end!!!\n");
            if (g_video_bsout && device->_data_callback) {
                cb_video_bs_info_t info;
                memset(&info,0,sizeof(cb_video_bs_info_t));
                info.device = device;
                info.end_flag = 1;
                (device->_data_callback)(device,CLOUD_CB_VIDEO_BS,&info,device->_data_context);
            } else if (device->_data_callback) {
                cb_video_info_t info;
                memset(&info,0,sizeof(cb_video_info_t));
                info.device = device;
                info.end_flag = 1;
                (device->_data_callback)(device,CLOUD_CB_VIDEO,&info,device->_data_context);
            }
        }
    } else if (ioType == IOTYPE_USER_IPCAM_DEVINFO_RESP) {
        SMsgAVIoctrlDeviceInfoResp *resp = (SMsgAVIoctrlDeviceInfoResp *)ioCtrlBuf;
        sprintf(device->version,"%s-%d",resp->model,resp->version);

    } else if (ioType == IOTYPE_USER_DEVICE_GET_CAMCFG_RESP) {
        SMsgAVIoctrlCamCfg *resp = (SMsgAVIoctrlCamCfg *)ioCtrlBuf;

        int cam_handle = resp->channel;
        cam_info_t *cam;
        if (device->cam[cam_handle].valid == 0) {
            printf("IOTYPE_USER_DEVICE_GET_CAMCFG_RESP: channel not exist!\n");
            return;
        }
        cam = &device->cam[cam_handle];
        device_cam_cfg_t cfg;
        cfg.battery_threshold = resp->battery_threshold;
        cfg.rotate = resp->cam_rotate;
        cfg.pir_sensitivity = resp->pir_sensitivity;
        strcpy(cfg.camdid , cam->cam_info.camdid);

        if (device->_event_callback) {
            device->_event_callback(device,CLOUD_CB_CAM_CFG,&cfg,device->_event_context);
        }
    } else if (ioType == IOTYPE_USER_DEVICE_GET_CAMINFO_RESP) {
        SMsgAVIoctrlCamInfo *resp = (SMsgAVIoctrlCamInfo *)ioCtrlBuf;

        int cam_handle = resp->channel;
        cam_info_t *cam;
        if (device->cam[cam_handle].valid == 0) {
            printf("IOTYPE_USER_DEVICE_GET_CAMCFG_RESP: channel not exist!\n");
            return;
        }
        cam = &device->cam[cam_handle];
        device_camera_info_t info;
        strncpy(info.verison, resp->version,sizeof(info.verison)-1);
        info.batttery = resp->battery;
        info.wifi = resp->wifi;
        strcpy(info.camdid , cam->cam_info.camdid);
        if (device->_event_callback) {
            device->_event_callback(device,CLOUD_CB_CAM_INFO,&info,device->_event_context);
        }
    } else if (ioType == IOTYPE_USER_DEVICE_SET_CAMCFG_RESP) {
        SMsgAVIoctrlCamResp *resp = (SMsgAVIoctrlCamResp *)ioCtrlBuf;

        int cam_handle = resp->channel;
        cam_info_t *cam;
        if (device->cam[cam_handle].valid == 0) {
            printf("IOTYPE_USER_DEVICE_SET_CAMCFG_RESP: channel not exist!\n");
            return;
        }
        cam = &device->cam[cam_handle];
        device_cam_result_t ret;
        ret.ret_val = resp->result;
        strcpy(ret.camdid , cam->cam_info.camdid);

        if (device->_event_callback) {
            device->_event_callback(device,CLOUD_CB_CAM_SET_CFG,&ret,device->_event_context);
        }
    }


}
static int send_heartbeat_cmd(cloud_device_t *device)
{
	int avIndex = device->avIndex;
	int ret;

    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_DEVINFO_REQ, NULL, 0)) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_DEVINFO_REQ failed[%d]\n", ret);
        pthread_mutex_unlock(&device->lock);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_DEVINFO_REQ OK\n");
    return 0;

}
static int _cloud_connect_device(cloud_device_t *device)
{
    CLOUD_PRINTF("cloud_connect_device ...%p, user %s, pass %s\n",device,device->username,device->password);

    device->videc_connect_err = 0;
    device->audio_connect_err = 0;
    device->cam_play_num = 0;
    device->audio_cam_id = -1;
    device->audio_stopping = 0;
    device->audio_stopped = 0;
    device->speak_cam_id = -1;
    device->speak_stopping = 0;
    device->speak_stopped = 0;
    device->seeking = 0;
    device->paused = 0;

    int ret;

	int tmpSID = IOTC_Get_SessionID();
	if(tmpSID < 0) {
		CLOUD_PRINTF("IOTC_Get_SessionID error code [%d]\n", tmpSID);
        if(IOTC_ER_NOT_INITIALIZED == tmpSID) {
            goto noinit_err;
        }
		goto conn_err;
	}
	CLOUD_PRINTF("  [] thread_ConnectCCR::IOTC_Get_SessionID, ret=[%d]\n", tmpSID);

	device->SID = IOTC_Connect_ByUID_Parallel(device->UID, tmpSID);
	CLOUD_PRINTF("  [] thread_ConnectCCR::IOTC_Connect_ByUID_Parallel, ret=[%d]\n", device->SID);
	if(device->SID < 0) {
		CLOUD_PRINTF("IOTC_Connect_ByUID_Parallel failed[%d]\n", device->SID);
		goto conn_err;
	}
    device->speakerCh = IOTC_Session_Get_Free_Channel(device->SID);
    printf("device->speakerCh = %d\n",device->speakerCh);

	struct st_SInfo Sinfo;
	memset(&Sinfo, 0, sizeof(struct st_SInfo));

	char *mode[] = {"P2P", "RLY", "LAN"};

	int nResend;
	unsigned int srvType;
	// The avClientStart2 will enable resend mechanism. It should work with avServerStart3 in device.
	//int avIndex = avClientStart(SID, avID, avPass, 20, &srvType, 0);
	device->avIndex = avClientStart2(device->SID, device->username, device->password, 20, &srvType, 0, &nResend);
	if(nResend == 0) {
        CLOUD_PRINTF("Resend is not supported.");
    }
	CLOUD_PRINTF("Step 2: call avClientStart2(%d).......\n", device->avIndex);
	if(device->avIndex < 0)
	{
		CLOUD_PRINTF("avClientStart2 failed[%d]\n", device->avIndex);
        goto conn_err;
	}
	int avIndex = device->avIndex;
	if(IOTC_Session_Check(device->SID, &Sinfo) == IOTC_ER_NoERROR)
	{
		if( isdigit( Sinfo.RemoteIP[0] ))
			CLOUD_PRINTF("Device is from %s:%d[%s] Mode=%s NAT[%d] IOTCVersion[%X]\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID, mode[(int)Sinfo.Mode], Sinfo.NatType, Sinfo.IOTCVersion);
	}
	CLOUD_PRINTF("avClientStart2 OK[%d], Resend[%d]\n", device->avIndex, nResend);

	if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_ADD_APPID, g_appinfo, APP_ID_LENGTH) < 0))
	{
		CLOUD_PRINTF("IOTYPE_USER_ADD_APPID failed[%d]\n", ret);
        goto conn_err;
	}
	CLOUD_PRINTF("send Cmd: IOTYPE_USER_ADD_APPID, OK\n");

	if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_GETCAMS, NULL, 0) < 0))
	{
		CLOUD_PRINTF("IOTYPE_USER_DEVICE_GETCAMS failed[%d]\n", ret);
        goto conn_err;
	}
	CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_GETCAMS, OK\n");

	unsigned int ioType;
	SMsgAVIoctrlCameraS cams;
    ret = avRecvIOCtrl(avIndex, &ioType, (char *)&cams, sizeof(SMsgAVIoctrlCameraS), 5000);
    if(ret >= 0) {
        if (ioType != IOTYPE_USER_DEVICE_GETCAMS) {
            CLOUD_PRINTF("avIndex[%d], avRecvIOCtrl ioType = %x\n",avIndex, ioType);
            goto conn_err;
        }
    } else {
        CLOUD_PRINTF("avIndex[%d], avRecvIOCtrl error, code[%d]\n",avIndex, ret);
        goto conn_err;
    }
    device->cam_num = (cams.num > DEVICE_CAM_NUM_MAX)?DEVICE_CAM_NUM_MAX:cams.num;
    CLOUD_PRINTF("cam_num %d\n",device->cam_num);

    pthread_mutex_lock(&device->lock);

    int i;
    int cam_handle;
    for(i=0;i<device->cam_num;i++) {
        cam_handle = cams.channel[i];
        CLOUD_PRINTF("cam channel %d\n",cam_handle);
        CLOUD_PRINTF("cam szCameraID %s\n",cams.szCameraID[i]);
        if (cam_handle > DEVICE_CAM_NUM_MAX) {
            CLOUD_PRINTF("invalid cam!!!!\n");
            device->cam_num = i;
            break;
        }
        device_cam_init(device,cam_handle,cams.szCameraID[i]);
        device->cam_sta[cam_handle] = 0;
    }
    pthread_mutex_unlock(&device->lock);


    return 0;
conn_err:
    CLOUD_PRINTF("_cloud_connect_device %p failed\n",device);

    if(device->avIndex >= 0) {
        avClientStop(device->avIndex);
        CLOUD_PRINTF("avClientStop avIndex %d OK\n",device->avIndex);
        device->avIndex = -1;
    }
    if (device->SID >= 0) {
        IOTC_Session_Close(device->SID);
        CLOUD_PRINTF("IOTC_Session_Close SID %d OK\n",device->SID);
        device->SID = -1;
    }

    return -1;
noinit_err:
    return -2;
}
int _cloud_forget_device(cloud_device_t *device)
{
    int ret;

    if(device->avIndex >= 0) {

        if((ret = avSendIOCtrl(device->avIndex, IOTYPE_USER_DEL_APPID, g_appinfo, APP_ID_LENGTH) < 0))
        {
            CLOUD_PRINTF("IOTYPE_USER_DEL_APPID failed[%d]\n", ret);
        }
        CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEL_APPID, OK\n");
    }

	return 0;
}
int _cloud_disconnect_device(cloud_device_t *device)
{
    device->speak_cam_id = -1;
    pthread_join(device->ThreadSpeaker_ID,NULL);

    if(device->avIndex >= 0) {

        avClientStop(device->avIndex);
        CLOUD_PRINTF("avClientStop avIndex %d OK\n",device->avIndex);
        device->avIndex = -1;
    }
    if (device->SID >= 0) {
        IOTC_Session_Close(device->SID);
        CLOUD_PRINTF("IOTC_Session_Close SID %d OK\n",device->SID);
        device->SID = -1;
    }
    pthread_mutex_lock(&device->lock);

    int i;
    for(i=0;i<DEVICE_CAM_NUM_MAX;i++) {
        if (device->cam[i].valid == 1) {
            device_cam_deinit(device,i);
        }
    }

    pthread_mutex_unlock(&device->lock);

	return 0;
}

int _cloud_device_play_video(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;

	int ret;
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));

    ioMsg.channel = cam_handle;
    device->play_seq++;
    ioMsg.reserved[0] = device->play_seq;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_START, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_START failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_START cam[%d], OK\n",ioMsg.channel);
    device->cam_play_num ++;
    CLOUD_PRINTF("cam_play_num = %d\n",device->cam_play_num);

    return 0;
}

int _cloud_device_stop_video(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;


	int ret;
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    avClientCleanBuf(cam_handle);

    ioMsg.channel = cam_handle;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_STOP, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_STOP failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_STOP cam[%d], OK\n",ioMsg.channel);

    device->cam_play_num --;

    CLOUD_PRINTF("cam_play_num = %d\n",device->cam_play_num);

    return 0;
}
int _cloud_device_play_audio(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;

    if (device->audio_cam_id >= 0) {
        printf("please stop old audio first!\n");
        return -1;
    }
	int ret;
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));

    ioMsg.channel = cam_handle;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_AUDIOSTART failed[%d]\n", ret);
        return -1;
     }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_AUDIOSTART cam[%d], OK\n",ioMsg.channel);


    device_audio_init(device);
    device->audio_cam_id = (int)cam_handle;

    return 0;
}
int _cloud_device_stop_audio(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;

    device->audio_stopping = 1;
    while(device->audio_stopped == 0) {
        usleep(10);
    }

    if (device->audio_cam_id >= 0) {
        device_audio_deinit(device);
    }
    device->audio_cam_id = -1;
    device->audio_stopping = 0;

	int ret;
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));

    ioMsg.channel = cam_handle;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTOP, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_AUDIOSTOP failed[%d]\n", ret);
        return -1;
     }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_AUDIOSTOP cam[%d], OK\n",ioMsg.channel);

    return 0;
}
int _cloud_device_speaker_enable(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;
	int ret;

    if (device->speak_cam_id >= 0) {
        printf("please stop old speak first!\n");
        return -1;
    }
    if ( (ret=pthread_create(&device->ThreadSpeaker_ID, NULL, &thread_SendAudio, (void *)device)) )
    {
        CLOUD_PRINTF("Create Audio send thread failed\n");
        return -1;
    }
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));

    ioMsg.channel = device->speakerCh;
    ioMsg.reserved[0] = (unsigned char)cam_handle;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_SPEAKERSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_SPEAKERSTART failed[%d]\n", ret);
        return -1;
     }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_SPEAKERSTART cam[%d], OK\n",ioMsg.channel);

    voice_data_clear();
    device->speak_cam_id = (int)cam_handle;
    device->speak_stopped = 0;

    return 0;
}
int _cloud_device_speaker_disable(cloud_device_t *device,int cam_handle)
{
	int avIndex = device->avIndex;


    device->speak_cam_id = -1;
    while(device->speak_stopped == 0) {
        usleep(10);
    }

    pthread_join(device->ThreadSpeaker_ID,NULL);

	int ret;
	SMsgAVIoctrlAVStream ioMsg;
	memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));

    ioMsg.channel = cam_handle;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_SPEAKERSTOP, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_SPEAKERSTOP failed[%d]\n", ret);
        return -1;
     }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_SPEAKERSTOP cam[%d], OK\n",ioMsg.channel);
    return 0;
}
cloud_cam_handle _cloud_device_probe_cam(cloud_device_t *device)
{
	int avIndex = device->avIndex;

    int ret;

	if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_PROBECAM, NULL,0) < 0))
	{
		CLOUD_PRINTF("IOTYPE_USER_DEVICE_PROBECAM failed[%d]\n", ret);
		return -1;
	}
	CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_PROBECAM, OK\n");

    return 0;
}
int _cloud_device_add_cam(cloud_device_t *device, SMsgAVIoctrlCamera *camctrl)
{
	int avIndex = device->avIndex;
    int ret;

	if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_ADDCAM, (char *)camctrl, sizeof(SMsgAVIoctrlCamera)) < 0))
	{
		CLOUD_PRINTF("IOTYPE_USER_DEVICE_ADDCAM failed[%d]\n", ret);
		return -1;
	}
	CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_ADDCAM, OK\n");

	/*
    device_cam_init(device,camctrl->channel,camctrl->szCameraID);
    device->cam_sta[camctrl->channel] = 0;
    device->cam_num ++;
    */

    return 0;
}

int _cloud_device_del_cam(cloud_device_t *device, SMsgAVIoctrlCamera *camctrl)
{
	int avIndex = device->avIndex;

    int ret;
	if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_DELCAM, (char *)camctrl, sizeof(SMsgAVIoctrlCamera)) < 0))
	{
		CLOUD_PRINTF("IOTYPE_USER_DEVICE_DELCAM failed[%d]\n", ret);
		return -1;
	}
	CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_DELCAM, OK\n");
/*
    device_cam_deinit(device,camctrl->channel);
    device->cam_num --;
*/
	return 0;
}


int _cloud_device_cam_list_files(cloud_device_t *device,SMsgAVIoctrlListYGEventReq *pblist)
{
	int avIndex = device->avIndex;

	int ret;

    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_LIST_YGEVENT_REQ, (char *)pblist, sizeof(SMsgAVIoctrlListYGEventReq))) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_LIST_YGEVENT_REQ failed[%d]\n", ret);
        return -1;
     }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_LIST_YGEVENT_REQ cam[%d], OK\n",pblist->channel);

    return 0;

}
int _cloud_device_cam_pb_ctrl(cloud_device_t *device,SMsgAVIoctrlPlayRecord *pbctrl)
{
	int avIndex = device->avIndex;
	int send_size = sizeof(SMsgAVIoctrlPlayRecord);

	if (pbctrl->command == AVIOCTRL_RECORD_PLAY_START) {
        if (device->audio_cam_id >= 0) {
            printf("please stop old audio first!\n");
            return -1;
        }
        send_size += 64;
        device->audio_cam_id = pbctrl->channel;
        device_audio_init(device);

        device->cam_play_num ++;
        char *fname = (char *)pbctrl + sizeof(SMsgAVIoctrlPlayRecord);
        printf("fname = %s\n",fname);

        device->play_seq ++;
        pbctrl->reserved[2] = device->play_seq;

	} else if (pbctrl->command == AVIOCTRL_RECORD_PLAY_STOP) {

        device->cam_play_num --;

        device->audio_stopping = 1;
        while(device->audio_stopped == 0) {
            usleep(10);
        }

        if (device->audio_cam_id >= 0) {
            device_audio_deinit(device);
        }
        device->audio_cam_id = -1;
        device->audio_stopping = 0;

	}
	int ret;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL, (char *)pbctrl, send_size)) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL cam[%d], OK\n",pbctrl->channel);

    return 0;
}
int _cloud_device_cam_set_cfg(cloud_device_t *device, SMsgAVIoctrlCamCfg *val)
{
	int avIndex = device->avIndex;
    int send_size = sizeof(SMsgAVIoctrlCamCfg);
	int ret;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_SET_CAMCFG_REQ, (char *)val, send_size)) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_DEVICE_SET_CAMCFG_REQ failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_SET_CAMCFG_REQ cam[%d], OK\n",val->channel);


    return 0;
}
int _cloud_device_cam_get_cfg(cloud_device_t *device,SMsgAVIoctrlCamera *val)
{
	int avIndex = device->avIndex;
    int send_size = sizeof(SMsgAVIoctrlCamera);
	int ret;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_GET_CAMCFG_REQ, (char *)val, send_size)) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_DEVICE_GET_CAMCFG_REQ failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_GET_CAMCFG_REQ cam[%d], OK\n",val->channel);


    return 0;
}
int _cloud_device_cam_get_info(cloud_device_t *device,SMsgAVIoctrlCamera *val)
{
	int avIndex = device->avIndex;
    int send_size = sizeof(SMsgAVIoctrlCamera);
	int ret;
    if((ret = avSendIOCtrl(avIndex, IOTYPE_USER_DEVICE_GET_CAMINFO_REQ, (char *)val, send_size)) < 0)
    {
        CLOUD_PRINTF("IOTYPE_USER_DEVICE_GET_CAMINFO_REQ failed[%d]\n", ret);
        return -1;
    }
    CLOUD_PRINTF("send Cmd: IOTYPE_USER_DEVICE_GET_CAMINFO_REQ cam[%d], OK\n",val->channel);


    return 0;
}
static void *thread_device(void *arg)
{
	CLOUD_PRINTF("[thread_device] Starting....\n");
    cloud_device_t *device = (cloud_device_t *)arg;
	int ret;
	cloud_device_state_t tmp_state;
	int avIndex;
	unsigned int ioType;
	char ioCtrlBuf[MAX_SIZE_IOCTRL_BUF];
    int timout_cnt = 0;
    cloud_cmd_t*  cmd;

	while(device->exit == 0)
	{
	    cmd = cloud_cmd_get(device->msgq);
        if (cmd != NULL) {
            if (cmd->m_msg.data[0] == DEVICE_CONNECT) {
                printf("device->cmd & DEVICE_CONNECT, state = %d\n",device->state);
                if (device->state == CLOUD_DEVICE_STATE_DISCONNECTED) {
                    ret = _cloud_connect_device(device);
                    if (ret  < 0 ) {
                        if (ret == -2) {
                            DEVICE_STATE_SET(device,CLOUD_DEVICE_STATE_UNINITILIZED);
                        } else {
                            DEVICE_STATE_SET(device,CLOUD_DEVICE_STATE_DISCONNECTED);
                        }
                    } else {
                        DEVICE_STATE_SET(device,CLOUD_DEVICE_STATE_CONNECTED);
                        send_heartbeat_cmd(device);
                    }
                }
                if (device->_callback) {
                    (device->_callback)(device,CLOUD_CB_STATE,&device->state,device->_context);
                }
                free_cmd(cmd);
                continue;
            } else if (cmd->m_msg.data[0] == DEVICE_DISCONNECT) {
                printf("device->cmd & DEVICE_DISCONNECT, state = %d\n",device->state);

                if (device->state == CLOUD_DEVICE_STATE_CONNECTED) {
                    _cloud_disconnect_device(device);
                    DEVICE_STATE_SET(device,CLOUD_DEVICE_STATE_DISCONNECTED);
                }
                if (device->_callback) {
                    (device->_callback)(device,CLOUD_CB_STATE,&device->state,device->_context);
                }
                free_cmd(cmd);
                continue;
            }
            if (device->state == CLOUD_DEVICE_STATE_CONNECTED) {

                if (cmd->m_msg.data[0] == PLAY_VIDEO) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_VIDEO) == 0) {
                        device->cam_sta[i] |= PLAY_VIDEO;
                        _cloud_device_play_video(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == STOP_VIDEO) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_VIDEO) != 0) {
                        device->cam_sta[i] &= ~PLAY_VIDEO;
                        _cloud_device_stop_video(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == PLAY_AUDIO) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_AUDIO) == 0) {
                        device->cam_sta[i] |= PLAY_AUDIO;
                        _cloud_device_play_audio(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == STOP_AUDIO) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_AUDIO) != 0) {
                        device->cam_sta[i] &= ~PLAY_AUDIO;
                        _cloud_device_stop_audio(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == PLAY_SPEAK) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_SPEAK) == 0) {
                        device->cam_sta[i] |= PLAY_SPEAK;
                        _cloud_device_speaker_enable(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == STOP_SPEAK) {
                    int i = cmd->m_msg.data[1];
                    if ((device->cam_sta[i] & PLAY_SPEAK) != 0) {
                        device->cam_sta[i] &= ~PLAY_SPEAK;
                        _cloud_device_speaker_disable(device,i);
                    }
                    free_cmd(cmd);
                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_PROBECAM) {

                    _cloud_device_probe_cam(device);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_ADDCAM) {
                    SMsgAVIoctrlCamera *camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

                    _cloud_device_add_cam(device,camctrl);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_DELCAM) {
                    SMsgAVIoctrlCamera *camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

                    _cloud_device_del_cam(device,camctrl);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_PBLIST) {
                    SMsgAVIoctrlListYGEventReq *pblist = (SMsgAVIoctrlListYGEventReq *)cmd->m_msg.ext;

                    _cloud_device_cam_list_files(device,pblist);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_PBCTRL) {
                    SMsgAVIoctrlPlayRecord *pbctrl = (SMsgAVIoctrlPlayRecord *)cmd->m_msg.ext;

                    _cloud_device_cam_pb_ctrl(device,pbctrl);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_CAM_SETCFG) {
                    SMsgAVIoctrlCamCfg *cfg = (SMsgAVIoctrlCamCfg *)cmd->m_msg.ext;

                    _cloud_device_cam_set_cfg(device,cfg);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_CAM_GETCFG) {
                    SMsgAVIoctrlCamera *camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

                    _cloud_device_cam_get_cfg(device,camctrl);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_CAM_GETINFO) {
                    SMsgAVIoctrlCamera *camctrl = (SMsgAVIoctrlCamera *)cmd->m_msg.ext;

                    _cloud_device_cam_get_info(device,camctrl);
                    free_cmd(cmd);

                    continue;
                } else if (cmd->m_msg.data[0] == DEVICE_FORGET) {
                    _cloud_forget_device(device);
                    free_cmd(cmd);

                    continue;
                }
            }
        }
        if (device->state != CLOUD_DEVICE_STATE_CONNECTED) {
            usleep(10000);
            continue;
        }

        tmp_state = device->state;
        avIndex = device->avIndex;
        ret = avRecvIOCtrl(avIndex, &ioType, (char *)ioCtrlBuf, MAX_SIZE_IOCTRL_BUF, 1000);
        if(ret >= 0)
        {
            CLOUD_PRINTF("recv_cmd ,type = %d\n",ioType);
            //Handle_IOCTRL_Cmd(SID, avIndex, ioCtrlBuf, ioType);
            process_recv_cmd(device,ioType,ioCtrlBuf);
            timout_cnt = 0;
        }
        else if(ret != AV_ER_TIMEOUT)
        {
            CLOUD_PRINTF("avIndex[%d], avRecvIOCtrl error, code[%d]\n",avIndex, ret);

            tmp_state = CLOUD_DEVICE_STATE_DISCONNECTED;

        } else if (timout_cnt == 15) {
            //CLOUD_PRINTF("avIndex[%d], avRecvIOCtrl war, code[%d]\n",avIndex, ret);
            if (send_heartbeat_cmd(device) == 0) {
                timout_cnt = 0;
            } else {
                timout_cnt ++;
            }
        } else if (timout_cnt > 15) {
            CLOUD_PRINTF("avIndex[%d], avRecvIOCtrl heartbeat timout, code[%d]\n",avIndex, ret);
            tmp_state = CLOUD_DEVICE_STATE_DISCONNECTED;
        } else {
            timout_cnt ++;
        }
        if (device->videc_connect_err == 1 || device->audio_connect_err == 1) {
            printf("videc_connect_err = %d, audio_connect_err = %d\n",device->videc_connect_err,device->audio_connect_err);
            tmp_state = CLOUD_DEVICE_STATE_DISCONNECTED;
        }

        if (tmp_state != device->state) {
            printf("tmp_state = %d, state = %d\n",tmp_state,device->state);
            DEVICE_STATE_SET(device,tmp_state);

            _cloud_disconnect_device(device);
            if (device->_callback) {
                (device->_callback)(device,CLOUD_CB_STATE,&device->state,device->_context);
            }
        }


	}
thread_end:
    if (device->state == CLOUD_DEVICE_STATE_CONNECTED) {
        _cloud_disconnect_device(device);
    }

	CLOUD_PRINTF("[thread_device] thread exit\n");

	return 0;
}


static void print_bitrate(cloud_device_t *device)
{
	int avIndex = device->avIndex;
    static int time_init = 0;
	static struct timeval tv, tv2;
	if (time_init == 0) {
        time_init = 1;
        gettimeofday(&tv, NULL);
	}
    gettimeofday(&tv2, NULL);
    long sec = tv2.tv_sec-tv.tv_sec, usec = tv2.tv_usec-tv.tv_usec;
    if(usec < 0)
    {
        sec--;
        usec += 1000000;
    }
    usec += (sec*1000000);

    if(usec > 1000000)
    {
        /*
        int i;
        for(i=0;i<DEVICE_CAM_NUM_MAX;i++) {
            cam_info_t *cam = &device->cam[i];
            if (cam->valid == 0)
                continue;
            CLOUD_PRINTF("[avIndex:%d] [cam:%d] FPS=%d, LostFrmCnt:%d, TotalCnt:%d, bps:%d Kbps\n", \
                    avIndex,i, cam->fpsCnt, cam->lostCnt, cam->cnt, (cam->bps/1024)*8);
            cam->fpsCnt = 0;
            cam->bps = 0;
        }
        */
        CLOUD_PRINTF("[avIndex:%d] FPS=%d, LostFrmCnt:%d, TotalCnt:%d, bps:%d Kbps\n", \
                avIndex, device->fpsCnt, device->lostCnt, device->cnt, (device->bps/1024)*8);
        device->fpsCnt = 0;
        device->bps = 0;
        gettimeofday(&tv, NULL);

    }
}

#define VIDEO_BUF_SIZE	256000

static void *thread_ReceiveVideo(void *arg)
{
	CLOUD_PRINTF("[thread_ReceiveVideo] Starting....\n");
    cloud_device_t *device = (cloud_device_t *)arg;
	int avIndex;
    char buf[VIDEO_BUF_SIZE]={0};
	int ret;

	FRAMEINFO_t frameInfo;
	unsigned int frmNo;
	int outBufSize = 0;
	int outFrmSize = 0;
	int outFrmInfoSize = 0;
	//int bCheckBufWrong;
	int new_stream_seq = 0;


	while(device->exit == 0)
	{
	    if (device->cam_play_num == 0 || device->avIndex < 0 || device->videc_connect_err == 1) {
			usleep(10 * 1000);
			continue;
	    }
	    avIndex = device->avIndex;
		//ret = avRecvFrameData(avIndex, buf, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
		ret = avRecvFrameData2(avIndex, buf, VIDEO_BUF_SIZE, &outBufSize, &outFrmSize, (char *)&frameInfo, sizeof(FRAMEINFO_t), &outFrmInfoSize, &frmNo);
		// show Frame Info at 1st frame
		//CLOUD_PRINTF("frmNo = %d,outBufSize = %d\n",frmNo,outBufSize);
		if(frmNo == 0)
		{
			char *format[] = {"MPEG4","H263","H264","MJPEG","UNKNOWN"};
			int idx = 0;
			if(frameInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4)
				idx = 0;
			else if(frameInfo.codec_id == MEDIA_CODEC_VIDEO_H263)
				idx = 1;
			else if(frameInfo.codec_id == MEDIA_CODEC_VIDEO_H264)
				idx = 2;
			else if(frameInfo.codec_id == MEDIA_CODEC_VIDEO_MJPEG)
				idx = 3;
			else
				idx = 4;
			CLOUD_PRINTF("--- Video Formate: %s ---\n", format[idx]);
		}
        //CLOUD_PRINTF("ret = %d,format %d, ts = %d\n",ret,frameInfo.codec_id,frameInfo.timestamp);
		if(ret == AV_ER_DATA_NOREADY) {
			//CLOUD_PRINTF("AV_ER_DATA_NOREADY[%d]\n", avIndex);
			usleep(10 * 1000);
			continue;
		}
		//CLOUD_PRINTF("decoded :camidx = %d\n",frameInfo.cam_index);
        cam_info_t *cam = &device->cam[frameInfo.cam_index];
        if (cam->valid == 0) {
            CLOUD_PRINTF("this cam not inited!\n");
			usleep(10 * 1000);
			continue;
        }

		if(ret == AV_ER_LOSED_THIS_FRAME) {
			CLOUD_PRINTF("Lost video frame NO[%d]\n", frmNo);
            device->lostCnt++;
			continue;
		} else if(ret == AV_ER_INCOMPLETE_FRAME) {
			CLOUD_PRINTF("AV_ER_INCOMPLETE_FRAME NO[%d]\n", frmNo);
			#if 1
			if(outFrmInfoSize > 0)
			CLOUD_PRINTF("Incomplete video frame NO[%d] ReadSize[%d] FrmSize[%d] FrmInfoSize[%u] Codec[%d] Flag[%d]\n", frmNo, outBufSize, outFrmSize, outFrmInfoSize, frameInfo.codec_id, frameInfo.flags);
			else
			CLOUD_PRINTF("Incomplete video frame NO[%d] ReadSize[%d] FrmSize[%d] FrmInfoSize[%u]\n", frmNo, outBufSize, outFrmSize, outFrmInfoSize);
			#endif
            device->lostCnt++;
            continue;
        } else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE) {
			CLOUD_PRINTF("[thread_ReceiveVideo] AV_ER_SESSION_CLOSE_BY_REMOTE\n");
			device->videc_connect_err = 1;//break;
			continue;
		} else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT) {
			CLOUD_PRINTF("[thread_ReceiveVideo] AV_ER_REMOTE_TIMEOUT_DISCONNECT\n");
			device->videc_connect_err = 1;//break;
			continue;
		} else if(ret == IOTC_ER_INVALID_SID) {
			CLOUD_PRINTF("[thread_ReceiveVideo] Session cant be used anymore\n");
			device->videc_connect_err = 1;//break;
			continue;
		} else {
			device->bps += outBufSize;
		}

        if (frameInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
            if (frameInfo.reserve1[0] != device->play_seq) {
                continue;
            }

            if (new_stream_seq != device->play_seq) {
                device_decoder_reset(device);
                device->play_timestamp_base = frameInfo.timestamp;
                new_stream_seq = device->play_seq;
                printf("device->play_seq = %d, device->play_timestamp_base = %d\n",device->play_seq,device->play_timestamp_base);
            }
            if (g_video_bsout && device->_data_callback && device->seeking == 0) {
                cb_video_bs_info_t info;
                memset(&info,0,sizeof(cb_video_bs_info_t));
                info.timestamp = frameInfo.timestamp-device->play_timestamp_base;
                info.device = device;
                strcpy(info.camdid , cam->cam_info.camdid);
                info.bs_data = buf;
                info.bs_size = outFrmSize;
                (device->_data_callback)(device,CLOUD_CB_VIDEO_BS,&info,device->_data_context);
            } else {
                //cam_video_dec(device,cam, buf, outFrmSize,frameInfo.timestamp-device->play_timestamp_base);
                device_video_dec(device, cam,buf, outFrmSize,frameInfo.timestamp-device->play_timestamp_base);
            }

        }
		device->cnt++;

		device->fpsCnt++;

		//print_bitrate(device);
	}

	//close_videoX(fd);
	CLOUD_PRINTF("[thread_ReceiveVideo] thread exit\n");

	return 0;
}
static int device_decoder_reset(cloud_device_t *device)
{
    printf("device_decoder_reset\n");
    if (device->video_codec_ctx) {
        avcodec_close(device->video_codec_ctx);
        av_free(device->video_codec_ctx);
        av_free_packet(&device->video_packet);
        FREE_FRAME(&device->video_pFrame_);
    }
	device->video_codec_ctx = avcodec_alloc_context3(videoCodec);//解码会话层
	if(!device->video_codec_ctx) {
		CLOUD_PRINTF("avcodec_alloc_context3  error\n");
		return -1;
	}
	if(avcodec_open2(device->video_codec_ctx, videoCodec, NULL) >= 0) {
		device->video_pFrame_ = ALLOC_FRAME();
		if (!device->video_pFrame_) {
			CLOUD_PRINTF("Could not allocate video frame\n");
            return -1;
		}
	} else {
		CLOUD_PRINTF("avcodec_open2 error\n");
		return -1;
	}

	av_init_packet(&device->video_packet);
	return 0;
}
static int device_cam_init(cloud_device_t *device,int camid, char *camdid)
{
    cam_info_t *cam = &device->cam[camid];
    memset(cam,0,sizeof(cam_info_t));

/*
	cam->video_codec_ctx = avcodec_alloc_context3(videoCodec);//解码会话层
	if(!cam->video_codec_ctx) {
		CLOUD_PRINTF("avcodec_alloc_context3  error\n");
		return -1;
	}
	if(avcodec_open2(cam->video_codec_ctx, videoCodec, NULL) >= 0) {
		cam->pFrame_ = ALLOC_FRAME();
		if (!cam->pFrame_) {
			CLOUD_PRINTF("Could not allocate video frame\n");
            return -1;
		}
	} else {
		CLOUD_PRINTF("avcodec_open2 error\n");
		return -1;
	}

	av_init_packet(&cam->packet);

	*/

    cam->valid = 1;
    strcpy(cam->cam_info.camdid,camdid);

    return 0;
}
static int device_cam_deinit(cloud_device_t *device,int camid)
{
    cam_info_t *cam = &device->cam[camid];
    if (cam->valid == 0) {
        return 0;
    }
    /*
	avcodec_close(cam->video_codec_ctx);
	av_free(cam->video_codec_ctx);
	av_free_packet(&cam->packet);
	FREE_FRAME(&cam->pFrame_);

    if (cam->pFrameOut) {
        FREE_FRAME(&cam->pFrameOut);
        cam->pFrameOut = NULL;
    }
    if (cam->dis_buffer) {
        av_free(cam->dis_buffer);
        cam->dis_buffer = NULL;
    }
    if (cam->img_convert_ctx != NULL) {
        sws_freeContext(cam->img_convert_ctx);
        cam->img_convert_ctx = NULL;
    }
    */
    if (cam->rec_info.blocks) {
        free(cam->rec_info.blocks);
    }
    strcpy(cam->cam_info.camdid,"");
    cam->valid = 0;

	return 0;
}

static void device_video_dec(cloud_device_t *device,cam_info_t *cam ,char* buf, int size,unsigned int timestamp)
{
    AVFrame *pFrame_ = device->video_pFrame_;
    device->video_packet.size = size;//将查找到的帧长度送入
    device->video_packet.data = (unsigned char *)buf;//将查找到的帧内存送入
    //CLOUD_PRINTF("video_dec_dis:%p,%d\n",buf,size);
/*
	video_codec_ctx->time_base.num = 1;
	video_codec_ctx->frame_number = 1; //每包一个视频帧
	video_codec_ctx->codec_type = AVMEDIA_TYPE_VIDEO;
	video_codec_ctx->bit_rate = 0;
	video_codec_ctx->time_base.den = 15;//帧率
	video_codec_ctx->width = 1920;//视频宽
	video_codec_ctx->height =1080;//视频高
*/
	int frameFinished = 0;//这个是随便填入数字，没什么作用
    int decodeLen = avcodec_decode_video2(device->video_codec_ctx, pFrame_, &frameFinished, &device->video_packet);
    if(decodeLen < 0) {
        CLOUD_PRINTF("decode fail!\n");
        device->video_packet.size = 0;
        device->video_packet.data = NULL;
        return;
    }
    //CLOUD_PRINTF("decodeLen = %d\n",decodeLen);
    device->video_packet.size -= decodeLen;
    device->video_packet.data += decodeLen;
    if(frameFinished > 0)//成功解码
    {
        int height = pFrame_->height;
        int width = pFrame_->width;
        //CLOUD_PRINTF("OK, get data\n");
        //CLOUD_PRINTF("Frame height is %d\n", height);
        //CLOUD_PRINTF("Frame width is %d\n", width);
        //CLOUD_PRINTF("Frame linesize is %d\n", pFrame_->linesize[0]);


        if (device->_data_callback && device->seeking == 0) {
            cb_video_info_t info;
            memset(&info,0,sizeof(cb_video_info_t));

            info.timestamp = timestamp;
            info.device = device;
            strcpy(info.camdid , cam->cam_info.camdid);

            //printf("b cam %d,frame %p\n",cam->cam_info.index,cam->pFrame_);
            info.pFrame = pFrame_;
            info.pix_buffer = pFrame_->data[0];
            info.width = width;
            info.height = height;
            info.org_width = width;
            info.org_height = height;

            info.format = AV_PIX_FMT_YUV420P;
            (device->_data_callback)(device,CLOUD_CB_VIDEO,&info,device->_data_context);
        }
        //CLOUD_PRINTF("777\n");

    }
}
#if 0
static void cam_video_dec(cloud_device_t *device,cam_info_t *cam , char* buf, int size,unsigned int timestamp)
{
    AVFrame *pFrame_ = cam->pFrame_;
    cam->packet.size = size;//将查找到的帧长度送入
    cam->packet.data = (unsigned char *)buf;//将查找到的帧内存送入
    //CLOUD_PRINTF("video_dec_dis:%p,%d\n",buf,size);
/*
	video_codec_ctx->time_base.num = 1;
	video_codec_ctx->frame_number = 1; //每包一个视频帧
	video_codec_ctx->codec_type = AVMEDIA_TYPE_VIDEO;
	video_codec_ctx->bit_rate = 0;
	video_codec_ctx->time_base.den = 15;//帧率
	video_codec_ctx->width = 1920;//视频宽
	video_codec_ctx->height =1080;//视频高
*/
	int frameFinished = 0;//这个是随便填入数字，没什么作用
    int decodeLen = avcodec_decode_video2(cam->video_codec_ctx, pFrame_, &frameFinished, &cam->packet);
    if(decodeLen < 0) {
        CLOUD_PRINTF("decode fail!\n");
        return;
    }
    //CLOUD_PRINTF("decodeLen = %d\n",decodeLen);
    cam->packet.size -= decodeLen;
    cam->packet.data += decodeLen;
    if(frameFinished > 0)//成功解码
    {
        int height = pFrame_->height;
        int width = pFrame_->width;
        //CLOUD_PRINTF("OK, get data\n");
        //CLOUD_PRINTF("Frame height is %d\n", height);
        //CLOUD_PRINTF("Frame width is %d\n", width);
        //CLOUD_PRINTF("Frame linesize is %d\n", pFrame_->linesize[0]);
        cam->frameCount ++;

        if (cam->pFrameOut) {
            if (width != cam->pic_width || height != cam->pic_height) {
                cam->pic_width = width;
                cam->pic_height = height;
                /*
                if (cam->pFrameOut) {
                    FREE_FRAME(&cam->pFrameOut);
                    cam->pFrameOut = NULL;
                }
                if (cam->dis_buffer) {
                    av_free(cam->dis_buffer);
                    cam->dis_buffer = NULL;
                }
                cam->dis_format = AV_PIX_FMT_RGB32;
                int numBytes = avpicture_get_size(cam->dis_format,cam->dis_width, cam->dis_height);
                cam->dis_buffer = (uint8_t *) av_malloc(numBytes * sizeof(uint8_t));
                if (cam->dis_buffer == NULL) {
                    return;
                }
                cam->pFrameOut = ALLOC_FRAME();
                avpicture_fill((AVPicture *) cam->pFrameOut, cam->dis_buffer, cam->dis_format,cam->dis_width, cam->dis_height);
                */
                if (cam->img_convert_ctx != NULL) {
                    sws_freeContext(cam->img_convert_ctx);
                    cam->img_convert_ctx = NULL;
                }
            }
            if (cam->img_convert_ctx == NULL) {
                cam->img_convert_ctx = sws_getContext(width, height, AV_PIX_FMT_YUV420P, cam->dis_width, cam->dis_height, cam->dis_format, SWS_BICUBIC, NULL, NULL, NULL);
            }
            if (cam->img_convert_ctx) {
                sws_scale(cam->img_convert_ctx,(uint8_t const * const *) pFrame_->data,pFrame_->linesize, 0, height, cam->pFrameOut->data,cam->pFrameOut->linesize);
            }
        }



        if (device->_data_callback && device->seeking == 0) {
            cb_video_info_t info;
            memset(&info,0,sizeof(cb_video_info_t));
            info.timestamp = timestamp;
            info.device = device;
            strcpy(info.camdid , cam->cam_info.camdid);
            if (cam->pFrameOut) {
                //printf("a cam %d,frame %p\n",cam->cam_info.index,cam->pFrameOut);
                info.pFrame = cam->pFrameOut;
                info.pix_buffer = cam->pFrame_->data[0];
                info.width = cam->dis_width;
                info.height = cam->dis_height;
                info.org_width = cam->pic_width;
                info.org_height = cam->pic_height;
            } else {
                //printf("b cam %d,frame %p\n",cam->cam_info.index,cam->pFrame_);
                info.pFrame = cam->pFrame_;
                info.pix_buffer = cam->pFrame_->data[0];
                info.width = cam->pic_width;
                info.height = cam->pic_height;
                info.org_width = cam->pic_width;
                info.org_height = cam->pic_height;
            }
            info.format = cam->dis_format;
            (device->_data_callback)(device,CLOUD_CB_VIDEO,&info,device->_data_context);
        }
        //CLOUD_PRINTF("777\n");
    }
}
#endif
#define AUDIO_BUF_SIZE	2048

static void *thread_ReceiveAudio(void *arg)
{
	CLOUD_PRINTF("[thread_ReceiveAudio] Starting....\n");
    cloud_device_t *device = (cloud_device_t *)arg;
	int avIndex;
    char buf[AUDIO_BUF_SIZE]={0};
	int ret;

	FRAMEINFO_t frameInfo;
	unsigned int frmNo;


	while(device->exit == 0)
	{
	    if (device->audio_stopping) {
            device->audio_stopped = 1;
			usleep(10 * 1000);
			continue;
        }
	    if (device->audio_cam_id < 0) {
            device->audio_stopped = 0;
			usleep(10 * 1000);
			continue;
	    }
	    if (device->avIndex < 0 || device->audio_connect_err == 1) {
			usleep(10 * 1000);
			continue;
	    }
	    avIndex = device->avIndex;

		ret = avRecvAudioData(avIndex, buf, AUDIO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
		// show Frame Info at 1st frame
		if(frmNo == 0)
		{
			char *format[] = {"ADPCM","PCM","SPEEX","MP3","G711U","UNKNOWN"};
			int idx = 0;
			if(frameInfo.codec_id == MEDIA_CODEC_AUDIO_ADPCM)
				idx = 0;
			else if(frameInfo.codec_id == MEDIA_CODEC_AUDIO_PCM)
				idx = 1;
			else if(frameInfo.codec_id == MEDIA_CODEC_AUDIO_SPEEX)
				idx = 2;
			else if(frameInfo.codec_id == MEDIA_CODEC_AUDIO_MP3)
				idx = 3;
			else if(frameInfo.codec_id == MEDIA_CODEC_AUDIO_G711U)
				idx = 4;
            else
				idx = 5;
			printf("--- Audio Formate: %s ---\n", format[idx]);
		}



		if(ret == AV_ER_DATA_NOREADY) {
			//CLOUD_PRINTF("AV_ER_DATA_NOREADY[%d]\n", avIndex);
			usleep(10 * 1000);
			continue;
		}
		if (frameInfo.cam_index != device->audio_cam_id) {
            CLOUD_PRINTF("audio decoded :camidx = %d\n",frameInfo.cam_index);
            continue;
		}
        cam_info_t *cam = &device->cam[frameInfo.cam_index];

		if(ret == AV_ER_LOSED_THIS_FRAME) {
			CLOUD_PRINTF("[thread_ReceiveAudio]Lost audio frame NO[%d]\n", frmNo);
			continue;
		} else if(ret == AV_ER_INCOMPLETE_FRAME) {
			CLOUD_PRINTF("[thread_ReceiveAudio]AV_ER_INCOMPLETE_FRAME NO[%d]\n", frmNo);
			continue;
        } else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE) {
			CLOUD_PRINTF("[thread_ReceiveAudio] AV_ER_SESSION_CLOSE_BY_REMOTE\n");
			device->audio_connect_err = 1;//break;
			continue;
		} else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT) {
			CLOUD_PRINTF("[thread_ReceiveAudio] AV_ER_REMOTE_TIMEOUT_DISCONNECT\n");
			device->audio_connect_err = 1;//break;
			continue;
		} else if(ret == IOTC_ER_INVALID_SID) {
			CLOUD_PRINTF("[thread_ReceiveAudio] Session cant be used anymore\n");
			device->audio_connect_err = 1;//break;
			continue;
		} else {
			//cam->bps += outBufSize;
		}
        if (g_audio_bsout && device->_data_callback && device->seeking == 0) {
            cb_audio_bs_info_t info;
            memset(&info,0,sizeof(cb_audio_bs_info_t));
            info.device = device;
            strcpy(info.camdid , cam->cam_info.camdid);
            info.bs_data = buf;
            info.bs_size = ret;
            (device->_data_callback)(device,CLOUD_CB_AUDIO_BS,&info,device->_data_context);
        } else {
            device_audio_dec(device,buf, ret);
        }


		//print_bitrate(device);
	}

	//close_videoX(fd);
	CLOUD_PRINTF("[thread_ReceiveAudio] thread exit\n");

	return 0;
}

static int device_audio_init(cloud_device_t *device)
{
	device->audio_codec_ctx = avcodec_alloc_context3(audioCodec);//解码会话层
	if(!device->audio_codec_ctx) {
		CLOUD_PRINTF("avcodec_alloc_context3  error\n");
		return -1;
	}
    device->audio_codec_ctx->channels = 1;
    device->audio_codec_ctx->sample_rate = 8000;
    device->audio_codec_ctx->bits_per_coded_sample = 8;
    device->audio_codec_ctx->bits_per_raw_sample = 16;
	if(avcodec_open2(device->audio_codec_ctx, audioCodec, NULL) < 0) {
		CLOUD_PRINTF("avcodec_open2 error\n");
		return -1;
	}
    device->audio_pFrame_ = ALLOC_FRAME();
    if (!device->audio_pFrame_) {
        CLOUD_PRINTF("Could not allocate audio frame\n");
        return -1;
    }
	av_init_packet(&device->audio_packet);
	CLOUD_PRINTF("audio_init ok!!!!\n");
    return 0;
}
static int device_audio_deinit(cloud_device_t *device)
{
	avcodec_close(device->audio_codec_ctx);
	av_free(device->audio_codec_ctx);
	av_free_packet(&device->audio_packet);
	FREE_FRAME(&device->audio_pFrame_);

	return 0;
}

static void device_audio_dec(cloud_device_t *device, char* buf, int size)
{
    //printf("device_audio_dec %p, %d\n",buf,size);
    device->audio_packet.size = size;//将查找到的帧长度送入
    device->audio_packet.data = (unsigned char *)buf;//将查找到的帧内存送入
    //CLOUD_PRINTF("video_dec_dis:%p,%d\n",buf,size);

/*
	int frame_size = sizeof(device->audio_sample);
    int decodeLen = avcodec_decode_audio3(device->audio_codec_ctx, (short *)device->audio_sample, &frame_size, &device->audio_packet);
*/
    //device->audio_codec_ctx->codec_type = AVMEDIA_TYPE_AUDIO;
/*
    device->audio_codec_ctx->frame_size = 960;
    device->audio_codec_ctx->channels = 1;
    device->audio_codec_ctx->sample_rate = 8000;
    device->audio_codec_ctx->bits_per_coded_sample = 8;
    device->audio_codec_ctx->bits_per_raw_sample = 16;
*/
	int frameFinished = 0;//这个是随便填入数字，没什么作用
    int decodeLen = avcodec_decode_audio4(device->audio_codec_ctx,device->audio_pFrame_,&frameFinished,&device->audio_packet);
    if(decodeLen < 0) {
        CLOUD_PRINTF("avcodec_decode_audio4 fail!\n");
        return;
    }
    //CLOUD_PRINTF("decodeLen = %d\n",decodeLen);
    device->audio_packet.size -= decodeLen;
    device->audio_packet.data += decodeLen;
    if(frameFinished > 0)//成功解码
    {
        if (device->_data_callback && device->seeking == 0) {
            cb_audio_info_t info;
            memset(&info,0,sizeof(cb_audio_info_t));
            info.device = device;
            info.pFrame = device->audio_pFrame_;
            //info.sample_buffer = device->audio_sample;
            //info.sample_length = decodeLen;
            (device->_data_callback)(device,CLOUD_CB_AUDIO,&info,device->_data_context);
        }
        //CLOUD_PRINTF("777\n");
    }
}
static int AuthCallBackFn(char *viewAcc,char *viewPwd)
{
	return 1;
}

static void *thread_SendAudio(void *arg)
{
	CLOUD_PRINTF("[thread_SendAudio] Starting....\n");
    cloud_device_t *device = (cloud_device_t *)arg;
    char *buf;

	FRAMEINFO_t frameInfo;
	CLOUD_PRINTF("Start IPCAM speak stream OK!\n");

	int size;

	int resend = 0;
    int avIndex = avServStart3(device->SID, AuthCallBackFn, 5, 0, device->speakerCh, &resend);
	//int avIndex = avServStart(device->SID, NULL, NULL, 50, 0, device->speakerCh);
	if(avIndex < 0)
	{
		printf("avServStart failed[%d]\n", avIndex);
        device->speak_stopped = 1;
		return 0;
	}
	printf("[thread_Speaker] Starting avIndex[%d] resend[%d]....\n", avIndex, resend);

	frameInfo.codec_id = MEDIA_CODEC_AUDIO_PCM;
	frameInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;


	while(device->speak_cam_id >= 0 && device->exit == 0)
	{
	    /*
	    if (device->speak_stopping) {
            voice_data_clear();
            device->speak_stopped = 1;
			usleep(10 * 1000);
			continue;
        }
	    if (device->speak_cam_id < 0) {
            device->speak_stopped = 0;
			usleep(10 * 1000);
			continue;
	    }
	    */

        size = voice_data_get(&buf,960);
        if (size <= 0) {
			usleep(10 * 1000);
			continue;
        }
        int ret = avSendAudioData(avIndex, buf, size, &frameInfo, sizeof(FRAMEINFO_t));
        if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            printf("thread_AudioFrameData AV_ER_SESSION_CLOSE_BY_REMOTE\n");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            printf("thread_AudioFrameData AV_ER_REMOTE_TIMEOUT_DISCONNECT\n");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            printf("Session cant be used anymore\n");
            break;
        }
        else if(ret < 0)
        {
            printf("avSendAudioData error[%d]\n", ret);
            break;
        }
        usleep(10*1000);

        //*** Speaker thread stop condition if necessary ***
	}


	avServStop(avIndex);

	CLOUD_PRINTF("[thread_Speaker] thread exit\n");
    device->speak_stopped = 1;

	return 0;
}

static unsigned char* voice_buf_buffer_addr = NULL;
static int voice_buf_buffer_size = 960*100;
static int voice_buf_wr = 0;
static int voice_buf_rd = 0;
static int voice_buf_unit_size = 0;

static int voice_data_get(unsigned char** addr,int max_size)
{
    int ret_size;
    if (voice_buf_buffer_addr == NULL) {
        return 0;
    }
    int period_bytes = max_size;
    int avai_size;
    int buf_wr = voice_buf_wr;
    if (buf_wr >= voice_buf_rd) {
        avai_size = buf_wr - voice_buf_rd;
    } else {
        avai_size = voice_buf_buffer_size - voice_buf_rd;
    }
    if (avai_size == 0) {
        *addr = NULL;
        return 0;
    } else if (avai_size >= period_bytes) {
        ret_size = period_bytes;
    }  else  {
        ret_size = avai_size;
    }
    *addr = (unsigned char*)(voice_buf_buffer_addr + voice_buf_rd);

    voice_buf_rd += ret_size;
    if (voice_buf_rd == voice_buf_buffer_size) {
        voice_buf_rd = 0;
    }
    return ret_size;

}


static int voice_data_put(unsigned char* addr,int size)
{
    //printf("feed <%d>\n",size);

    int empty_size;

    if (voice_buf_buffer_addr == NULL || size != voice_buf_unit_size) {
        if (voice_buf_buffer_addr != NULL) {
            free(voice_buf_buffer_addr);
        }
        voice_buf_buffer_size = size*100;
        voice_buf_unit_size = size;
        voice_buf_buffer_addr = malloc(voice_buf_buffer_size);
        if (voice_buf_buffer_addr == NULL) {
            printf("MALLOC playbuf failed!\n");
            return -1;
        }
        voice_buf_wr = voice_buf_rd = 0;
    }
    int buf_rd = voice_buf_rd;
    if (voice_buf_wr >= buf_rd) {
        empty_size = voice_buf_buffer_size - (voice_buf_wr - buf_rd) -1;
    } else {
        empty_size = buf_rd - voice_buf_wr -1;
    }
    //printf("empty_size %d , play_size %d\n",empty_size,size);
    if (empty_size < size) {
        printf("empty_size < size, rd=%d,wr=%d,bufsize=%d\n",buf_rd , voice_buf_wr, voice_buf_buffer_size);
        return 0;
    }
    if (voice_buf_buffer_size - voice_buf_wr >= size) {
        memcpy(voice_buf_buffer_addr+voice_buf_wr,addr,size);
        voice_buf_wr += size;
        if (voice_buf_wr == voice_buf_buffer_size) {
            voice_buf_wr = 0;
        }
    } else {
        memcpy(voice_buf_buffer_addr+voice_buf_wr, addr, voice_buf_buffer_size - voice_buf_wr);
        memcpy(voice_buf_buffer_addr,addr+ (voice_buf_buffer_size - voice_buf_wr), size - (voice_buf_buffer_size - voice_buf_wr));
        voice_buf_wr = size - (voice_buf_buffer_size - voice_buf_wr);
    }
    //printf("service_audio_player_feed: %x, %d,  r %d, w %d\n",voice_buf_buffer_addr,voice_buf_buffer_size,buf_rd,voice_buf_wr);

    return 0;
}
static void voice_data_clear()
{
    voice_buf_wr = voice_buf_rd = 0;
}
static int find_cam(cloud_device_t *device,const char* camdid)
{
    int i;
    if (camdid == NULL) {
        return -1;
    }
    for(i=0;i<DEVICE_CAM_NUM_MAX;i++) {
        if (device->cam[i].valid == 1) {
            if (strcmp(device->cam[i].cam_info.camdid,camdid) == 0) {
                return i;//&device->cam[i];
            }
        }
    }
    return -1;
}


static cloud_cmd_queue_t* ut_msgq_create()
{
    cloud_cmd_queue_t* p_msgq_ctx;

    p_msgq_ctx = malloc(sizeof(cloud_cmd_queue_t));
    memset(p_msgq_ctx,0,sizeof(cloud_cmd_queue_t));

    ut_vmutex_create_recur(p_msgq_ctx->m_mutex, "msgq");

    printf("msgq = %p, cnt = %d\n", p_msgq_ctx,p_msgq_ctx->m_count);

    return p_msgq_ctx;
}

static int ut_msgq_destroy(cloud_cmd_queue_t *p_msgq_ctx)
{
    ut_vmutex_destroy(p_msgq_ctx->m_mutex);

    free(p_msgq_ctx);

    return 0;
}
static int cloud_cmd_put(cloud_cmd_queue_t *p_msgq_ctx,cloud_cmd_t *p_msg_node)
{
    ut_vmutex_lock(p_msgq_ctx->m_mutex);

    p_msg_node->m_prev = p_msgq_ctx->m_last;
    p_msg_node->m_next = NULL;
    if(p_msgq_ctx->m_last)
    {
        p_msgq_ctx->m_last->m_next = p_msg_node;
    }
    if(!p_msgq_ctx->m_first)
    {
        p_msgq_ctx->m_first = p_msg_node;
    }
    p_msgq_ctx->m_last = p_msg_node;
    p_msgq_ctx->m_count++;

    //ut_vcond_broadcast(p_msgq_ctx->m_cond);

    ut_vmutex_unlock(p_msgq_ctx->m_mutex);
        printf(" ======> cloud_cmd_putt :msgq = %p,  %p, %x,  msg_cnt = %d\n",p_msgq_ctx,p_msg_node,p_msg_node->m_msg.data[0],  p_msgq_ctx->m_count);
    return 0;
}
static cloud_cmd_t* cloud_cmd_get(cloud_cmd_queue_t *p_msgq_ctx)
{
    cloud_cmd_t* p_msg_node = NULL;

    ut_vmutex_lock(p_msgq_ctx->m_mutex);
    if(p_msgq_ctx->m_first)
    {
        cloud_cmd_t* p_msg_node_next = p_msgq_ctx->m_first->m_next;
        p_msg_node = p_msgq_ctx->m_first;
        p_msgq_ctx->m_first = p_msg_node_next;
        if(p_msgq_ctx->m_first)
        {
            p_msgq_ctx->m_first->m_prev = NULL;
        }
        else
        {
            p_msgq_ctx->m_last = NULL;
        }
        p_msgq_ctx->m_count--;
    }
    ut_vmutex_unlock(p_msgq_ctx->m_mutex);
    if (p_msg_node) {
        printf(" <====== cloud_cmd_get : %p, %x,  msg_cnt = %d\n",p_msg_node,p_msg_node->m_msg.data[0],  p_msgq_ctx->m_count);

    }
    return p_msg_node;
}
static int cloud_cmd_clear(cloud_cmd_queue_t *p_msgq_ctx)
{
    ut_vmutex_lock(p_msgq_ctx->m_mutex);

    cloud_cmd_t* p_msg_node = p_msgq_ctx->m_first;
    while(p_msg_node)
    {
        cloud_cmd_t* p_msg_node_next = p_msg_node->m_next;
        free(p_msg_node);
        p_msg_node = p_msg_node_next;
    }
    p_msgq_ctx->m_first = NULL;
    p_msgq_ctx->m_last = NULL;
    p_msgq_ctx->m_count = 0;

    ut_vmutex_unlock(p_msgq_ctx->m_mutex);

    return 0;
}
static cloud_cmd_t* new_cmd(unsigned int cmd_type, int size)
{
    cloud_cmd_t *cmd = malloc(sizeof(cloud_cmd_t));
    if (cmd == NULL) {
        return NULL;
    }
    memset(cmd,0,sizeof(cloud_cmd_t));
    cmd->m_msg.data[0] = cmd_type;
    if (size > 0) {
        cmd->m_msg.ext = malloc(size);
        if (cmd->m_msg.ext == NULL) {
            free(cmd);
            return NULL;
        }
    }
    return cmd;
}
static void free_cmd(cloud_cmd_t *cmd)
{
    if (cmd->m_msg.ext != NULL) {
        free(cmd->m_msg.ext);
    }
    free(cmd);
}
