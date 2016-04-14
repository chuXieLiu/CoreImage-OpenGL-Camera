//
//  CXMovieWriter.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXMovieWriter.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CXContextManager.h"
#import "CXCameraNotification.h"
#import "CXPhotoFilter.h"
#import "UIView+CXExtension.h"

@interface CXMovieWriter ()

@property (nonatomic,strong) NSDictionary *videoSettings;

@property (nonatomic,strong) NSDictionary *audioSettings;

@property (nonatomic,strong) dispatch_queue_t dispatchQueue;

@property (nonatomic,strong) CIContext *ciContext;

@property (nonatomic,assign) CGColorSpaceRef colorSpace;

@property (nonatomic,strong) CIFilter *filter;

@property (nonatomic,strong) AVAssetWriter *assetWriter;

@property (nonatomic,strong) AVAssetWriterInput *assetWriterVideoInput;

@property (nonatomic,strong) AVAssetWriterInput *assetWriterAudioInput;

// 拼接样本适配器
@property (nonatomic,strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

// 是否是第一次取样
@property (nonatomic,assign) BOOL isFirstSample;

@property (nonatomic,assign) BOOL isWriting;

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
        
        
        NSError *error;
        
        // asset writer AVFileTypeQuickTimeMovie
        
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL]
                                                    fileType:AVFileTypeQuickTimeMovie error:&error];
        
        if (!self.assetWriter || error) {
            NSLog(@"error could not create AVAssetWriter");
            return ;
        }
        
        // video input AVMediaTypeVideo
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:self.videoSettings];
        
        // 实时调整输入
        
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        self.assetWriterVideoInput.transform = CXTransformForDeviceOrientation(orientation);
        
        // buffer adaptor
        
        NSDictionary *attributes = @{
                                     (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (NSString *)kCVPixelBufferWidthKey : self.videoSettings[AVVideoWidthKey],
                                     (NSString *)kCVPixelBufferHeightKey : self.videoSettings[AVVideoHeightKey],
                                     (NSString *)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue
                                     
                                     };
        
        self.assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput sourcePixelBufferAttributes:attributes];
        
        
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        } else {
            NSLog(@"error could not add AVAssetWriterInput");
            return;
        }
        
        // audio input AVMediaTypeAudio
        
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:self.audioSettings];
        
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            
            [self.assetWriter addInput:self.assetWriterAudioInput];
            
        } else {
            NSLog(@"error could not add AVAssetWriterInput");
            
        }
        
        self.isFirstSample = YES;
        
        self.isWriting = YES;
        
    });
}


- (void)stopWriting
{
    self.isWriting = NO;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.dispatchQueue, ^{
       
        [self.assetWriter finishWritingWithCompletionHandler:^{
            
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                    [weakSelf writeMovieAtURL:self.assetWriter.outputURL];
            }
            
        }];
        
    });
}


- (void)writeMovieAtURL:(NSURL *)outputURL {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KCXCameraWillWriteVideoNotification object:nil userInfo:nil];
    });
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL
        completionBlock:^(NSURL *assetURL, NSError *error) {

            if (error) {
                NSLog(@"write video error");
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KCXCameraWriteVideoCompletionNotification object:assetURL userInfo:nil];
                });
            }
        }];
    }
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!self.isWriting) {
        return;
    }
    
    // 获取样本的媒体类型
    
    CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(format);
    
    if (mediaType == kCMMediaType_Video) {
        
        // 
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (self.isFirstSample) {
            
            // 第一次写入，设置开始时间
            
            if ([self.assetWriter startWriting]) {
                
                [self.assetWriter startSessionAtSourceTime:timestamp];
                
            } else {
                NSLog(@"error failed to start writing");
            }
            
            self.isFirstSample = NO;
        }
        
        // 容器
        CVPixelBufferRef outputRenderBuffer = NULL;
        
        // 像素缓冲池
        CVPixelBufferPoolRef pixelBufferPool = self.assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        
        // 创建像素容器
        CVReturn code =  CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        
        if (code != kCVReturnSuccess) {
            NSLog(@"error to get pixel buffer from pool");
            return;
        }
        
        // 获取每一帧
        CVPixelBufferRef imagebuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imagebuffer options:nil];
        
        // 添加滤镜
        
        [self.filter setValue:sourceImage forKey:kCIInputImageKey];
        
        CIImage *filteredImage = self.filter.outputImage;
        
        if (!filteredImage) {
            filteredImage = sourceImage;
        }
        
        // 开始拼接滤镜图片
        
        [self.ciContext render:filteredImage toCVPixelBuffer:outputRenderBuffer bounds:filteredImage.extent colorSpace:self.colorSpace];
        
        bool isReady = self.assetWriterVideoInput.readyForMoreMediaData;
        
        if (isReady) {
            // 适配器拼接处理结果
            bool result = [self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timestamp];
            if (!result) {
                NSLog(@"error appending pixel buffer");
            }
        }
        
        CVPixelBufferRelease(outputRenderBuffer);
    } else if (!self.isFirstSample && mediaType == kCMMediaType_Audio) {    // 直接拼接音频
        bool isReady = self.assetWriterAudioInput.readyForMoreMediaData;
        if (isReady) {
            // 直接从样本中拼接音频
            bool result = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
            if (!result) {
                NSLog(@"error appending audio sample buffer");
            }
        }
    }
    
}

CGAffineTransform CXTransformForDeviceOrientation(UIDeviceOrientation orientation) {
    
    CGAffineTransform result;
    
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default: // UIDeviceOrientationLandscapeLeft
            result = CGAffineTransformIdentity;
            break;
    }
    
    return result;
}

@end
