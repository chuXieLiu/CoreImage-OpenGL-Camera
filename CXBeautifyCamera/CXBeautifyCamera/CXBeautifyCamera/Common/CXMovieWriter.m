//
//  CXMovieWriter.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXMovieWriter.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import "CXContextManager.h"
#import "CXCameraNotification.h"
#import "CXPhotoFilter.h"

@interface CXMovieWriter ()

@property (nonatomic,strong) NSDictionary *videoSettings;

@property (nonatomic,strong) NSDictionary *audioSettings;

@property (nonatomic,strong) dispatch_queue_t dispatchQueue;

@property (nonatomic,strong) CIContext *ciContext;

@property (nonatomic,assign) CGColorSpaceRef colorSpace;

@property (nonatomic,strong) CIFilter *filter;

@property (nonatomic,strong) AVAssetWriter *assetWriter;

// 是否是第一次取样
@property (nonatomic,assign) BOOL isFirstSample;

@end

@implementation CXMovieWriter


- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self = [super init];
    if (self) {
        self.videoSettings = videoSettings;
        self.audioSettings = audioSettings;
        self.dispatchQueue = dispatchQueue;
        self.ciContext = [CXContextManager sharedManager].ciContext;
        self.colorSpace = CGColorSpaceCreateDeviceRGB();
        self.filter = [CXPhotoFilter defaultFilter];
        self.isFirstSample = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDidChange:) name:kCXCameraFitlerDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    CGColorSpaceRelease(self.colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - target event

- (void)filterDidChange:(NSNotification *)note
{
    CIFilter *filter = note.object;
    self.filter = filter;
}

- (NSURL *)outputURL {
    NSString *filePath =
    [NSTemporaryDirectory() stringByAppendingPathComponent:@"movie.mov"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

- (void)startWriting
{
    dispatch_async(self.dispatchQueue, ^{
        
        
        
    });
}










@end
