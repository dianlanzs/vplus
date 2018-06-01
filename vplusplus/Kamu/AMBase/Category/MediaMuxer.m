//
//  MediaMuxer.m
//  测试Demo
//
//  Created by Zhoulei on 2018/3/12.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "MediaMuxer.h"

//#include "MyMuxerToMP4.h"
#include <stdio.h>


//编解码器 算法结构
#include <libavcodec/avcodec.h>

//av 格式
#include <libavformat/avformat.h>
//
#include <stdlib.h>





#ifdef _WIN32


//Windows 系统
extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
};
#else


//Linux... 系统
#ifdef __cplusplus  //定义了 C++
extern "C"
{
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#ifdef __cplusplus
};
#endif
#endif


#define __STDC_CONSTANT_MACROS












//
//extern "C"
//{
//#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
//#include "libavcodec/avcodec.h"
#include "libswresample/swresample.h"
#include "libavutil/frame.h"
#include "libavutil/samplefmt.h"
//#include "libavformat/avformat.h"
//#include "libavcodec/avcodec.h"
//}
//
//#pragma comment(lib, "avcodec.lib")
//#pragma comment(lib, "avdevice.lib")
//#pragma comment(lib, "avformat.lib")
//#pragma comment(lib, "avutil.lib")
//#pragma comment(lib, "swscale.lib")
//#pragma comment(lib, "swresample.lib")
















@implementation MediaMuxer

/**
 *最简单的基于FFmpeg的音频编码器
 *Simplest FFmpeg Audio Encoder
 *
 *雷霄骅 Lei Xiaohua
 *leixiaohua1020@126.com
 *中国传媒大学/数字电视技术
 *Communication University of China / Digital TV Technology
 *http://blog.csdn.net/leixiaohua1020
 *
 *本程序实现了音频PCM采样数据编码为压缩码流（MP3，WMA，AAC等）。
 *是最简单的FFmpeg音频编码方面的教程。
 *通过学习本例子可以了解FFmpeg的编码流程。
 *This software encode PCM data to AAC bitstream.
 *It's the simplest audio encoding software based on FFmpeg.
 *Suitable for beginner of FFmpeg
 */


int flush_encoder(AVFormatContext *fmt_ctx,unsigned int stream_index){
    int ret;
    int got_frame;
    AVPacket enc_pkt;
    if (!(fmt_ctx->streams[stream_index]->codec->codec->capabilities &
          CODEC_CAP_DELAY))
        return 0;
    while (1) {
        enc_pkt.data = NULL;
        enc_pkt.size = 0;
        av_init_packet(&enc_pkt);
        ret = avcodec_encode_audio2 (fmt_ctx->streams[stream_index]->codec, &enc_pkt,
                                     NULL, &got_frame);
        av_frame_free(NULL);
        if (ret < 0)
            break;
        if (!got_frame){
            ret=0;
            break;
        }
        printf("Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n",enc_pkt.size);
        /* mux encoded frame */
        ret = av_write_frame(fmt_ctx, &enc_pkt);
        if (ret < 0)
            break;
    }
    return ret;
}

int pcmToAacEncoding(const char *input_pcmFilePath, const char *output_aacFilePath) {
//- (int)pcmToAacEncoding:(const char *)input_pcmFilePath aacFile:(const char *)output_aacFilePath{
    AVFormatContext* pFormatCtx;
    AVOutputFormat* fmt;
    AVStream* audio_st;
    AVCodecContext* pCodecCtx;
    AVCodec* pCodec;
 
    
    
    uint8_t* frame_buf;
    AVFrame* pFrame;
    AVPacket pkt;
    
    int got_frame=0;
    int ret=0;
    int size=0;
    
    FILE *in_file=NULL;                         //Raw PCM data

    int framenum = 1000;                          //Audio frame number
    
    //MARK:====== file url ===============
//    const char* out_file = "tdjm.aac";          //Output URL
    
    const char* out_file = output_aacFilePath;
    int i;
    
//    in_file= fopen("tdjm.pcm", "rb");
    in_file= fopen(input_pcmFilePath, "rb");

    
    
    
    //注册FFmpeg的所有编解码器。
    av_register_all();
    
    //Method 1.
    pFormatCtx = avformat_alloc_context(); //初始化输出码流的AVFormatContext
    fmt = av_guess_format(NULL, out_file, NULL); //根据文件格式,自动探测输出文件格式 、、
    pFormatCtx->oformat = fmt;
    
    /*
     AVCodecContext *c;
     AVStream *st;
     
     
     ///////////////////////////////////////////////
     AVCodec *codec;
     codec = avcodec_find_encoder(AV_CODEC_ID_AAC);
     
     if(NULL == codec)
     {
     printf("没有找到合适的编码器！\n");
     }
     
     st = avformat_new_stream(oc, codec);
     
     if (st==NULL)
     {
     printf("输出文件打开失败！\n");
     }
     
     c = st->codec;
     
     
     c->codec = codec;                                      1
     c->codec_id =  AV_CODEC_ID_AAC;                        2
     c->codec_type = AVMEDIA_TYPE_AUDIO;                    3
     c->sample_fmt = AV_SAMPLE_FMT_S16;                     4
     c->sample_rate= 44100;                                 5
     c->channel_layout=AV_CH_LAYOUT_STEREO;                 6
     //    c->channels = //av_get_channel_layout_nb_channels(audioCodecCtx->channel_layout)//; 7
     //    c->bit_rate = 16000;                             8
     //    c->strict_std_compliance = FF_COMPLIANCE_EXPERIMENTAL;        //10
     //
     //    codec->profiles = FF_PROFILE_AAC_MAIN;         //11
     //    int a[]= {AV_SAMPLE_FMT_S16};
     //    codec->sample_fmts = a;
     //
     //    return st;
     //     */
    
    
    //Method 2.
    //avformat_alloc_output_context2(&pFormatCtx, NULL, NULL, out_file);
    //fmt = pFormatCtx->oformat;
    
    //Open output URL
    if (avio_open(&pFormatCtx->pb,out_file, AVIO_FLAG_READ_WRITE) < 0){
        printf("Failed to open output file!\n");
        return -1;
    }

    audio_st = avformat_new_stream(pFormatCtx, 0); //先初始化 id = 0
    if (audio_st==NULL){
        return -1;
    }
    
    
    
    
    
    
    
    
    ///////////////////////////////////////////////

    //I1: audioCodec->sample_fmt = audioCodec->codec->sample_fmts[0];
    pCodecCtx = audio_st->codec; //获取 流上下文环境
    
    //***** 创建 AAC 编码器 *****
    AVCodec *codec;
    codec = avcodec_find_encoder(AV_CODEC_ID_AAC);
    if(NULL == codec)
    {
        printf("没有找到合适的编码器！\n");
    }
    
    
    //  I2: pCodecCtx->codec_id = fmt->audio_codec; //id
    
    pCodecCtx->codec = codec; //设置 上下文 里的 AAC 编码器
    pCodecCtx->codec_id = AV_CODEC_ID_AAC; //编码器类型ID
    pCodecCtx->codec_id = fmt->audio_codec; //id

    pCodecCtx->codec_type = AVMEDIA_TYPE_AUDIO;
    pCodecCtx->sample_fmt = AV_SAMPLE_FMT_S16; //2 byte   、、AV_SAMPLE_FMT_FLTP，  AAC 只支持 AV_SAMPLE_FMT_FLTP， 必须保证  PCM 是FLTP 格式 而不是  AV_SAMPLE_FMT_S16（2Byte)格式
    pCodecCtx->sample_rate= 8000;  //44100 ，一秒钟采样频率
    pCodecCtx->channel_layout=AV_CH_LAYOUT_STEREO;  //布局
    pCodecCtx->channels = av_get_channel_layout_nb_channels(pCodecCtx->channel_layout);
    pCodecCtx->bit_rate = 64000;//64KBps
    pCodecCtx->strict_std_compliance =FF_COMPLIANCE_EXPERIMENTAL; //2015.5 以后不支持这个参数了
    
    
    
//    codec->profiles = FF_PROFILE_AAC_MAIN;
    int a[]= {AV_SAMPLE_FMT_S16};  ///MARK: 数组 设置 支持的 采样格式！！
    codec->sample_fmts = a;  // 注释 会  导致  Failed to open encoder!\n
    //Show some information
    av_dump_format(pFormatCtx, 0, out_file, 1);
    
    //audioCodec->profile = FF_PROFILE_AAC_MAIN
    //    pCodec = avcodec_find_encoder(AV_CODEC_ID_AAC);
    pCodec = avcodec_find_encoder(pCodecCtx->codec_id);
    if (!pCodec){
        printf("Can not find encoder!\n");
        return -1;
//        return;

    }
    if (avcodec_open2(pCodecCtx, pCodec,NULL) < 0){
        printf("Failed to open encoder!\n");
        return -1;
//        return;

    }
    pFrame = av_frame_alloc();
    pFrame->nb_samples= pCodecCtx->frame_size;
    pFrame->format= pCodecCtx->sample_fmt;
    
    size = av_samples_get_buffer_size(NULL, pCodecCtx->channels,pCodecCtx->frame_size,pCodecCtx->sample_fmt, 1);
    frame_buf = (uint8_t *)av_malloc(size);
    avcodec_fill_audio_frame(pFrame, pCodecCtx->channels, pCodecCtx->sample_fmt,(const uint8_t*)frame_buf, size, 1);
    
    //Write Header
    avformat_write_header(pFormatCtx,NULL);  // 产生 log: Using AVStream.codec.time_base as a timebase hint to the muxer is deprecated. Set AVStream.time_base instead.
    
    av_new_packet(&pkt,size);
    
    
    
    
    
    for (i=0; i<framenum; i++)
    {
        //Read PCM
        if (fread(frame_buf, 1, size, in_file) <= 0){
            printf("Failed to read raw data! \n");
            return -1;
//            return ;
        }else if(feof(in_file)){
            break;
        }
        pFrame->data[0] = frame_buf;  //PCM Data
        
        pFrame->pts=i*100;
        got_frame=0;
        
        
        
        //Encode
        ret = avcodec_encode_audio2(pCodecCtx, &pkt,pFrame, &got_frame);
        if(ret < 0){
            printf("Failed to encode!\n");
            return -1;
        }
        if (got_frame==1){
            printf("Succeed to encode 1 frame! \tsize:%5d\n",pkt.size);
            pkt.stream_index = audio_st->index;
            ret = av_write_frame(pFormatCtx, &pkt);
            av_free_packet(&pkt);
        }
    }
    
    
    
    
    
    
    
    
    
    
    //Flush Encoder
    ret = flush_encoder(pFormatCtx,0);
    if (ret < 0) {
        printf("Flushing encoder failed\n");
        return -1;
    }
    
    //Write Trailer
    av_write_trailer(pFormatCtx);
    
    //Clean
    if (audio_st){
        avcodec_close(audio_st->codec);
        av_free(pFrame);
        av_free(frame_buf);
    }
    avio_close(pFormatCtx->pb);
    avformat_free_context(pFormatCtx);
    
    fclose(in_file);
    
    return 0;
}



/*
 FIX: H.264 in some container format (FLV, MP4, MKV etc.) need
 "h264_mp4toannexb" bitstream filter (BSF)
 *Add SPS,PPS in front of IDR frame
 *Add start code ("0,0,0,1") in front of NALU
 H.264 in some container (MPEG2TS) don't need this BSF.
 */
//'1': Use H.264 Bitstream Filter
#define USE_H264BSF 1 //Bitstream Filter

/*
 FIX:AAC in some container format (FLV, MP4, MKV etc.) need
 "aac_adtstoasc" bitstream filter (BSF)
 */
//'1': Use AAC Bitstream Filter
#define USE_AACBSF 1 //Bitstream Filter



static long open_input_file(const char *filename) //int
{
    FILE *fp;
    fp = fopen(filename,"rb");// localfile文件名
    if (!fp) {
        return 0;
    }
    fseek(fp,0L,SEEK_END); /* 定位到文件末尾 */
    long flen = ftell(fp); /* 得到文件大小 */  //int
    //printf("=====22222======filename %s,length:%d",filename,flen);
    
    return flen;
}

int muxer_main(const char *inputH264FileName, const char *inputPcmFileName, const char *outMP4FileName, const char* angle)
{
    AVOutputFormat *ofmt = NULL;
    //Input AVFormatContext and Output AVFormatContext
    AVFormatContext *ifmt_ctx_v = NULL, *ifmt_ctx_a = NULL,*ofmt_ctx = NULL;
    AVPacket pkt;
    AVCodec *dec;
    int ret, i;
    int videoindex_v=-1,videoindex_out=-1;
    int audioindex_a=-1,audioindex_out=-1;
    int frame_index=0;
    int64_t cur_pts_v=0,cur_pts_a=0;
    
    //const char *in_filename_v = "cuc_ieschool.ts";//Input file URL
    const char *in_filename_v =inputH264FileName;
    //const char *in_filename_a = "cuc_ieschool.mp3";
    //const char *in_filename_a = "gowest.m4a";
    //const char *in_filename_a = "gowest.aac";
    const char *in_filename_a =inputPcmFileName;
    
    const char *out_filename =outMP4FileName;//Output file URL
    
    printf("==========in h264==filename:%s\n",in_filename_v);
    printf("==========in aac ===filename:%s\n",in_filename_a);
    
    
    //int video_length=open_input_file(in_filename_v);
    //=========判断如果视频中没有音频，会导致avformat_find_stream_info退出程序======
    long acc_length = open_input_file(in_filename_a); //如果音频是空，则不需要放入视频
    
    avcodec_register_all();
    av_register_all();
    
    
    
     //Input
     if ((ret = avformat_open_input(&ifmt_ctx_a, in_filename_a, NULL, NULL)) < 0) {
     //        printf("=====11========RET:%d\n",ret);
     printf( "Could not open input file.");
     goto end;
     }
     //    printf("=====2========RET:%d\n",ret);
     if ((ret = avformat_find_stream_info(ifmt_ctx_a, 0)) < 0) {
     printf( "Failed to retrieve input stream information");
     if(acc_length>0) //如果音频是空，则直接到结尾，否则继续运行
     goto end;
     }
    
    
    
    
    
    
    if ((ret = avformat_open_input(&ifmt_ctx_v, in_filename_v, NULL, NULL)) < 0) {
        printf( "Could not open input file:%d\n",ret);
        goto end;
    }
    //    printf("=====0========RET:%d\n",ret);
    if ((ret = avformat_find_stream_info(ifmt_ctx_v, 0)) < 0) {
        printf( "Failed to retrieve input stream information");
        goto end;
    }
    
    //    /* init the video decoder */
    //    if ((ret = avcodec_open2(ifmt_ctx_a->, dec, NULL)) < 0) {
    //        printf( "Cannot open video decoder\n");
    //        return ret;
    //    }
    //
    
    
    printf("===========Input Information==========\n");
    av_dump_format(ifmt_ctx_v, 0, in_filename_v, 0);
    //    av_dump_format(ifmt_ctx_a, 0, in_filename_a, 0);
    printf("======================================\n");
    //Output
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        printf( "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    ofmt = ofmt_ctx->oformat;
    
    for (i = 0; i < ifmt_ctx_v->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(ifmt_ctx_v->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            AVStream *in_stream = ifmt_ctx_v->streams[i];
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
            videoindex_v=i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            videoindex_out=out_stream->index;
            //Copy the settings of AVCodecContext
            ret = av_dict_set(&out_stream->metadata,"rotate",angle,0); //设置旋转角度
            if(ret>=0)
            {
                printf("=========yes=====set rotate success!===:%s\n",angle);
            }
            
            if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
                goto end;
            }
            out_stream->codec->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
            break;
        }
    }
    
    if(acc_length>0) //如果音频文件有内容，则读取，否则为空读取会失败
    {
        for (i = 0; i < ifmt_ctx_a->nb_streams; i++) {
            
            printf("===========acc=====from======:%d\n",ifmt_ctx_a->nb_streams);
            //Create output AVStream according to input AVStream
            if(ifmt_ctx_a->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
                AVStream *in_stream = ifmt_ctx_a->streams[i];
                AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
                audioindex_a=i;
                if (!out_stream) {
                    printf( "Failed allocating output stream\n");
                    ret = AVERROR_UNKNOWN;
                    goto end;
                }
                audioindex_out=out_stream->index;
                //Copy the settings of AVCodecContext
                if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                    printf( "Failed to copy context from input to output stream codec context\n");
                    goto end;
                }
                out_stream->codec->codec_tag = 0;
                if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                    out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
                
                break;
            }
        }
    }
    
    printf("==========Output Information==========\n");
    av_dump_format(ofmt_ctx, 0, out_filename, 1);
    printf("======================================\n");
    //Open output file
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        if (avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE) < 0) {
            printf( "Could not open output file '%s'", out_filename);
            goto end;
        }
    }
    
    
    
    //Write file header
    int header_ret=avformat_write_header(ofmt_ctx, NULL);
    if (header_ret< 0) {
        printf( "Error occurred when opening output file:%d\n",header_ret);
        goto end;
    }
    
    
    //FIX
#if USE_H264BSF
    AVBitStreamFilterContext* h264bsfc =  av_bitstream_filter_init("h264_mp4toannexb");
#endif
#if USE_AACBSF
    AVBitStreamFilterContext* aacbsfc =  av_bitstream_filter_init("aac_adtstoasc");
#endif
    
    while (1) {
        AVFormatContext *ifmt_ctx;
        int stream_index=0;
        AVStream *in_stream, *out_stream;
        
        
        //Get an AVPacket
        
        int compare_tag=-1;
        if(acc_length>0) //既然没有音频，则直接判断写入视频
        {
            compare_tag =av_compare_ts(cur_pts_v,ifmt_ctx_v->streams[videoindex_v]->time_base,cur_pts_a,ifmt_ctx_a->streams[audioindex_a]->time_base) ;
        }
        
        if(compare_tag<= 0){
            ifmt_ctx=ifmt_ctx_v;
            stream_index=videoindex_out;
            
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==videoindex_v){
                        //FIX£∫No PTS (Example: Raw H.264)
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        }
                        
                        cur_pts_v=pkt.pts;
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
        }else{
            ifmt_ctx=ifmt_ctx_a;
            stream_index=audioindex_out;
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==audioindex_a){
                        
                        //FIX£∫No PTS
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        }
                        cur_pts_a=pkt.pts;
                        
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
            
        }
        
        //FIX:Bitstream Filter
#if USE_H264BSF
        av_bitstream_filter_filter(h264bsfc, in_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
#if USE_AACBSF
        av_bitstream_filter_filter(aacbsfc, out_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
        
        
        //Convert PTS/DTS
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        pkt.stream_index=stream_index;
        
        printf("Write 1 Packet. size:%5d\tpts:%lld\n",pkt.size,pkt.pts);
        //Write
        
        if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
            printf( "Error muxing packet\n");
            break;
        }
        
        
        av_free_packet(&pkt);
        
    }
    //Write file trailer
    av_write_trailer(ofmt_ctx);
    
#if USE_H264BSF
    av_bitstream_filter_close(h264bsfc);
#endif
#if USE_AACBSF
    av_bitstream_filter_close(aacbsfc);
#endif
    
end:
    avformat_close_input(&ifmt_ctx_v);
    avformat_close_input(&ifmt_ctx_a);
    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_close(ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);
    if (ret < 0 && ret != AVERROR_EOF) {
        printf( "Error occurred.\n");
        return -1;
    }
    
    printf("======muxer mp4 success =====!\n");
    return 0;
}



















//
//
///* PCM转AAC */
//int pcmToAac(const char *input_pcmFilePath,  const char *output_aacFilePath){
//    /* ADTS头 */
//    char *padts = (char *)malloc(sizeof(char) * 7);
//    int profile = 2;    //AAC LC
//    int freqIdx = 4;  //44.1KHz
//    int chanCfg = 2;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center,channel_layout.h
//    padts[0] = (char)0xFF; // 11111111     = syncword
//    padts[1] = (char)0xF1; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
//    padts[2] = (char)(((profile - 1) << 6) + (freqIdx << 2) + (chanCfg >> 2));
//    padts[6] = (char)0xFC;
//    
//    SwrContext *swr_ctx = NULL;
//    AVCodecContext *pCodecCtx = NULL;
//    AVCodec *pCodec = NULL;
//    AVFrame *pFrame;
//    AVPacket pkt;
//    enum AVCodecID codec_id = AV_CODEC_ID_AAC;
//    
//    FILE *fp_in;
//    FILE *fp_out;
////    char filename_in[] = "audio.pcm";
//   const char *filename_in = input_pcmFilePath;
//   const  char *filename_out = output_aacFilePath;
////    char filename_out[] = "audio.aac";
//    
//    uint8_t **convert_data;         //存储转换后的数据，再编码AAC
//    int i, ret, got_output;
//    uint8_t* frame_buf;
//    int size = 0;
//    int y_size;
//    int framecnt = 0;
//    int framenum = 100000;
//    
//    
//    avcodec_register_all();
//    
//    pCodec = avcodec_find_encoder(codec_id);
//    if (!pCodec) {
//        printf("Codec not found\n");
//        return -1;
//    }
//    
//    pCodecCtx = avcodec_alloc_context3(pCodec);
//    if (!pCodecCtx) {
//        printf("Could not allocate video codec context\n");
//        return -1;
//    }
//    
//    pCodecCtx->codec_id = codec_id;
//    pCodecCtx->codec_type = AVMEDIA_TYPE_AUDIO;
//    pCodecCtx->sample_fmt = AV_SAMPLE_FMT_FLTP;
//    pCodecCtx->sample_rate = 44100;
//    pCodecCtx->channel_layout = AV_CH_LAYOUT_STEREO;
//    pCodecCtx->channels = av_get_channel_layout_nb_channels(pCodecCtx->channel_layout);
//    
//    
////
////    qDebug() << "pCodecCtx->bit_rate ----------------> " << pCodecCtx->bit_rate;
////    qDebug() << "pCodecCtx->bit_rate ----------------> " << pCodecCtx->bit_rate;
////    qDebug() << av_get_channel_layout_nb_channels(pCodecCtx->channel_layout);
//    
//    
//    if ((ret = avcodec_open2(pCodecCtx, pCodec, NULL)) < 0) {
////        qDebug() << "avcodec_open2 error ----> " << ret;
//            NSLog(@"avcodec_open2 error");
//        
//        printf("Could not open codec\n");
//        return -1;
//    }
//    
//    pFrame = av_frame_alloc();
//    pFrame->nb_samples = pCodecCtx->frame_size;   //1024
//    pFrame->format = pCodecCtx->sample_fmt;
//    pFrame->channels = 2;
////    qDebug() << "frame_size(set pFrame->nb_samples) -------------> " << pCodecCtx->frame_size;
//    
//    
//    
//    /* 由AV_SAMPLE_FMT_FLT转为AV_SAMPLE_FMT_FLTP */
//    swr_ctx = swr_alloc_set_opts(
//                                 NULL,
//                                 av_get_default_channel_layout(pCodecCtx->channels),
//                                 pCodecCtx->sample_fmt,                   //在编码前，我希望的采样格式
//                                 pCodecCtx->sample_rate,
//                                 av_get_default_channel_layout(pCodecCtx->channels),
//                                 AV_SAMPLE_FMT_S16,                      //PCM源文件的采样格式 AV_SAMPLE_FMT_FLT
//                                 pCodecCtx->sample_rate,
//                                 0, NULL);
//    
//    swr_init(swr_ctx);
//    /* 分配空间 */
//    convert_data = (uint8_t**)calloc(pCodecCtx->channels,
//                                     sizeof(*convert_data));
//    av_samples_alloc(convert_data, NULL,
//                     pCodecCtx->channels, pCodecCtx->frame_size,
//                     pCodecCtx->sample_fmt, 0);
//    
//    
//    
//    size = av_samples_get_buffer_size(NULL, pCodecCtx->channels, pCodecCtx->frame_size, pCodecCtx->sample_fmt, 0);
//    
//    frame_buf = (uint8_t *)av_malloc(size);
//    /* 此时data[0],data[1]分别指向frame_buf数组起始、中间地址 */
//    ret = avcodec_fill_audio_frame(pFrame, pCodecCtx->channels, pCodecCtx->sample_fmt, (const uint8_t*)frame_buf, size, 0);
//    
//    if (ret < 0)
//    {
//        
//        NSLog(@"avcodec_fill_audio_frame error");
////        qDebug() << "avcodec_fill_audio_frame error ";
//        return 0;
//    }
//    
//    //Input raw data
//    fp_in = fopen(filename_in, "rb");
//    if (!fp_in) {
//        printf("Could not open %s\n", filename_in);
//        return -1;
//    }
//    
//    //Output bitstream
//    fp_out = fopen(filename_out, "wb");
//    if (!fp_out) {
//        printf("Could not open %s\n", filename_out);
//        return -1;
//    }
//    
//    //Encode
//    for (i = 0; i < framenum; i++) {
//        av_init_packet(&pkt);
//        pkt.data = NULL;    // packet data will be allocated by the encoder
//        pkt.size = 0;
//        //Read raw data
//        if (fread(frame_buf, 1, size, fp_in) <= 0) {
//            printf("Failed to read raw data! \n");
//            return -1;
//        }
//        else if (feof(fp_in)) {
//            break;
//        }
//        /* 转换数据，令各自声道的音频数据存储在不同的数组（分别由不同指针指向）*/
//        swr_convert(swr_ctx, convert_data, pCodecCtx->frame_size,
//                    (const uint8_t**)pFrame->data, pCodecCtx->frame_size);
//        
//        /* 将转换后的数据复制给pFrame */
//        int length = pCodecCtx->frame_size * av_get_bytes_per_sample(pCodecCtx->sample_fmt);
//        for (int k = 0; k < 2; ++k)
//            for (int j = 0; j < length; ++j)
//            {
//                pFrame->data[k][j] = convert_data[k][j];
//            }
//        
//        pFrame->pts = i;
//        
////        qDebug() << "frame->nb_samples -----> " << pFrame->nb_samples;
////        qDebug() << "size ------------------> " << size;
////        qDebug() << "frame->linesize[0] ----> " << pFrame->linesize[0];
//        
//        
//        
//        ret = avcodec_encode_audio2(pCodecCtx, &pkt, pFrame, &got_output);
//        
//        if (ret < 0) {
////            qDebug() << "error encoding";
//            return -1;
//        }
//        
//        if (pkt.data == NULL)
//        {
//            av_free_packet(&pkt);
//            continue;
//        }
//        
////        qDebug() << "got_ouput = " << got_output;
//        if (got_output) {
////            qDebug() << "Succeed to encode frame : " << framecnt << " size :" << pkt.size;
//            
//            framecnt++;
//            
//            padts[3] = (char)(((chanCfg & 3) << 6) + ((7 + pkt.size) >> 11));
//            padts[4] = (char)(((7 + pkt.size) & 0x7FF) >> 3);
//            padts[5] = (char)((((7 + pkt.size) & 7) << 5) + 0x1F);
//            fwrite(padts, 7, 1, fp_out);
//            fwrite(pkt.data, 1, pkt.size, fp_out);
//            
//            av_free_packet(&pkt);
//        }
//    }
//    //Flush Encoder
//    for (got_output = 1; got_output; i++) {
//        ret = avcodec_encode_audio2(pCodecCtx, &pkt, NULL, &got_output);
//        if (ret < 0) {
//            printf("Error encoding frame\n");
//            return -1;
//        }
//        if (got_output) {
//            printf("Flush Encoder: Succeed to encode 1 frame!\tsize:%5d\n", pkt.size);
//            padts[3] = (char)(((chanCfg & 3) << 6) + ((7 + pkt.size) >> 11));
//            padts[4] = (char)(((7 + pkt.size) & 0x7FF) >> 3);
//            padts[5] = (char)((((7 + pkt.size) & 7) << 5) + 0x1F);
//            
//            fwrite(padts, 7, 1, fp_out);
//            fwrite(pkt.data, 1, pkt.size, fp_out);
//            av_free_packet(&pkt);
//        }
//    }
//    
//    fclose(fp_out);
//    avcodec_close(pCodecCtx);
//    av_free(pCodecCtx);
//    av_freep(&pFrame->data[0]);
//    av_frame_free(&pFrame);
//    
//    av_freep(&convert_data[0]);
//    free(convert_data);
//    //////////////////////////////////////////////////////////////////////////////////
//    
//    return 0;
//}
//







@end





