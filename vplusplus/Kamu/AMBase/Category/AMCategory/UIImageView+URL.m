//
//  UIImageView+URL.m
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import "UIImageView+URL.h"

@implementation UIImageView (URL)

-(void)imageWithURL:(NSURL *)url {
    [self performSelectorInBackground:@selector(loadImageWithURL:) withObject:url];
}

-(void)loadImageWithURL:(NSURL *)url {
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imgData];
    [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
}

@end
