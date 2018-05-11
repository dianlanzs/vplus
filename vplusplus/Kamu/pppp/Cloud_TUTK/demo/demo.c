#include "cloud.h"

//#define SDL_DISPLAY

#ifdef SDL_DISPLAY
    #include "SDL/SDL.h"
    static SDL_Surface* screen = NULL;
    static SDL_Rect rect;
#endif // SDL_DISPLAY

static int g_stop = 0;

static device_cam_info_t g_cam_info[4];
static int g_cam_num = 0;
int my_device_status_callback(int type, void *param,void *context)
{
    printf("status_callback:type %d, param %s, context %p\n",type,param,context);

    return 0;
}
int my_device_data_callback(int type, void *param,void *context)
{
    //printf("data_callback:type %d, param %s, context %p\n",type,param,context);

    if (type == CLOUD_CB_VIDEO) {
        cb_video_info_t *info = (cb_video_info_t *)param;
        AVFrame *pFrame_ = info->pFrame;
        cloud_cam_id cam_id = info->cam_id;

        int height = pFrame_->height;
        int width = pFrame_->width;

    #ifdef SDL_DISPLAY
        SDL_Overlay* overlay = (SDL_Overlay*)context;

        SDL_LockYUVOverlay(overlay);
        int i;
        for(i=0;i<height;i++)
        {//fwrite(buf + i * wrap, 1, xsize, f);
             memcpy(overlay->pixels[0]+i*width, pFrame_->data[0]+i*pFrame_->linesize[0], width);
        }
        for(i=0;i<(height>>1);i++)
        {
            memcpy(overlay->pixels[2]+i*(width>>1), pFrame_->data[1]+i*pFrame_->linesize[1], width>>1);
            memcpy(overlay->pixels[1]+i*(width>>1), pFrame_->data[2]+i*pFrame_->linesize[2], width>>1);
        }
        SDL_UnlockYUVOverlay(overlay);
        //SDL_UnlockSurface(screen);
        rect.w = width;
        rect.h = height;
        if (cam_id == g_cam_info[0].index) {
            rect.x = 0;
            rect.y = 0;
        } else if (cam_id == g_cam_info[1].index) {
            rect.x = 640;
            rect.y = 0;
        } else if (cam_id == g_cam_info[2].index) {
            rect.x = 0;
            rect.y = 360;
        } else if (cam_id == g_cam_info[3].index) {
            rect.x = 640;
            rect.y = 360;
        }
        SDL_DisplayYUVOverlay(overlay, &rect);
    #endif
    }

    return 0;
}
int main(int argc, char *argv[])
{
#ifdef SDL_DISPLAY
    SDL_Init(SDL_INIT_VIDEO);
    atexit(SDL_Quit);
    screen = SDL_SetVideoMode( 1280, 720, 32, SDL_SWSURFACE );
    if (screen == NULL) {
        printf("screen NULL!\n");
        return -1;
    }
#endif // SDL_DISPLAY

    /*step 1: init cloud*/
    cloud_init();

    /*step 2: connect device*/

    cloud_device_handle device = cloud_connect_device("FNKUA574PNVMVNPGYHW1","admin","123");
    if (device == NULL) {
        printf("cloud_connect_device fail!\n");
        return -1;
    }

    /*step 3: register callback if needed*/

    cloud_set_status_callback(device,my_device_status_callback,NULL);


    /*step 4: check how many cams have been added onto the device.
    If device type == IPC, always 1 cam; if NVR or GW, 0 or 1 cam default.*/
    g_cam_num = cloud_device_get_cams(device, 4, g_cam_info);
    printf("g_cam_num = %d\n",g_cam_num);

    /*step 5: if 1 or more cams exist, play one of the cams; else add one cam and play it*/
#ifdef SDL_DISPLAY
    SDL_Overlay* overlay = SDL_CreateYUVOverlay(640, 360, SDL_YV12_OVERLAY, screen);
    if (overlay == NULL) {
        printf("overlay NULL!\n");
        return -1;
    }
    cloud_set_data_callback(device,my_device_data_callback,(void*)overlay);
#endif

    if (g_cam_num > 0) {
        cloud_device_play_video(device,g_cam_info[0].index);
    } else {
        strcpy(g_cam_info[0].camdid,"test00001");
        g_cam_info[0].index = cloud_device_add_cam(device,g_cam_info[0].camdid);
        if (g_cam_info[0].index >= 0) {
            g_cam_num ++;
            cloud_device_play_video(device,g_cam_info[0].index);
        }
    }
#ifdef SDL_DISPLAY

    SDL_Event event;
    while (g_stop == 0)
    {
        while (SDL_PollEvent(&event))
        {
            // check for messages
            switch (event.type)
            {
                printf("event = %d\n",event.type);
                // exit if the window is closed
            case SDL_QUIT:
                g_stop = 1;
                break;

                // check for keypresses
            case SDL_KEYDOWN:
                {
                    // exit if ESCAPE is pressed
                    if (event.key.keysym.sym == SDLK_ESCAPE)
                        g_stop = 1;
                    break;
                }
            } // end switch
        } // end of message processing
        usleep(1000);
    }
#endif

    if (g_cam_num > 0) {
        cloud_device_stop_video(device,g_cam_info[0].index);
    }

    cloud_disconnect_device(device);

    cloud_exit();
#ifdef SDL_DISPLAY
    if (overlay != NULL) {
        SDL_FreeYUVOverlay(overlay);
    }
    if (screen != NULL) {
        SDL_FreeSurface(screen);
    }
    //Quit SDL
    SDL_Quit();
#endif



    return 0;
}
