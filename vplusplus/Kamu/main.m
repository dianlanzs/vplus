//
//  main.m
//  Kamu
//
//  Created by tom on 2017/11/10.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//#import "sys/socket.h"
#include <sys/socket.h>



#include <signal.h>


















void sigpipe_handler(int unused){
    printf("Caught signal SIGPIPE %d\n",unused);

}


//void signal_callback_handler(int signum){
//
//    printf("Caught signal SIGPIPE %d\n",signum);
//}

int main(int argc, char * argv[]) {
    

    @autoreleasepool {
//            signal(SIGPIPE,SIG_IGN);
//        struct sigaction sa;
//        sa.sa_handler = SIG_IGN;
//        sigaction( SIGPIPE, &sa, 0 );
//

//
//        struct sigaction sa_pipe;
//        sa_pipe.sa_handler = SIG_IGN;
//        sigaction(SIGPIPE, &sa_pipe, NULL);
//
//        sigset_t signal_mask;
//        sigemptyset (&signal_mask);
//        sigaddset (&signal_mask, SIGPIPE);
//        int rc = pthread_sigmask (SIG_BLOCK, &signal_mask, NULL);
//        if (rc != 0)
//        {
//            printf("block sigpipe error/n");
//        }
        
        
        
        
        struct sigaction sa;
        
        sa.sa_handler = SIG_IGN;
        
        sigaction( SIGPIPE, &sa, 0 );
        
//        sigaction(SIGPIPE, &osa, 0);
        
        
        
//        signal(SIGPIPE, SIG_IGN);
//        
//        sigset_t signal_mask;
//        sigemptyset (&signal_mask);
//        sigaddset (&signal_mask, SIGPIPE);
//        int rc = pthread_sigmask (SIG_BLOCK, &signal_mask, NULL);
//        if (rc != 0)
//        {
//            printf("block sigpipe error\n");
//        }
        
        
        
        
        
        
        
        
        
        
        
        
        
//        int value = 1;
//        // sock 就是设置不发送 `SIGPIPE` 信号的 socket 变量
//        setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(value));
//        signal(SIGPIPE, SIG_IGN);
        
        

        
        
        
        
//        signal(SIGPIPE, SIG_IGN);

        
        
        /* Catch Signal Handler SIGPIPE */
//        signal(SIGPIPE, signal_callback_handler);
      
        
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
