//
//  CXBeautifyCameraManager.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXBeautifyCameraManager.h"
#import <AVFoundation/AVFoundation.h>

@interface CXBeautifyCameraManager ()
<
    AVCaptureVideoDataOutputSampleBufferDelegate,
    AVCaptureAudioDataOutputSampleBufferDelegate
>

@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;

@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;


@property (nonatomic,strong,readwrite) dispatch_queue_t captureQueue;


@end

@implementation CXBeautifyCameraManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.captureQueue = dispatch_queue_create("com.camera.CaptureDispatchQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void)setupCaptureSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    NSError *error;
    
    // video input
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.videoInput = videoInput;
        }
    }

    // audio input
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    }
    
    // video data output
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 在跟OpenGL ES上，苹果建议使用kCVPixelFormatType_32BGRA
    
    NSDictionary *videoSettings = @{
                                    (NSString *)kCVPixelBufferPixelFormatTypeKey:
                                        @(kCVPixelFormatType_32BGRA)
                                    };
    
    videoDataOutput.videoSettings = videoSettings;
    
    // 捕捉全部可用帧，保持实时性，会带来一定内存消耗
    
    videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
        
    [videoDataOutput setSampleBufferDelegate:self
                                       queue:self.captureQueue];
    
    if ([self.captureSession canAddOutput:videoDataOutput]) {
        [self.captureSession addOutput:videoDataOutput];
        self.videoDataOutput = videoDataOutput;
    }
    
    // audio data output
    
    AVCaptureAudioDataOutput *audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    
    [audioDataOutput setSampleBufferDelegate:self
                                       queue:self.captureQueue];
    
    if ([self.captureSession canAddOutput:audioDataOutput]) {
        [self.captureSession addOutput:audioDataOutput];
    }
    
    
}


- (void)startCaptureSession
{
    dispatch_async(self.captureQueue, ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
}


- (void)stopCaptureSession
{
    dispatch_async(self.captureQueue, ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });
}


- (void)startRecorded
{
    
}


- (void)stopRecorded
{
    
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == self.videoDataOutput) {
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:NULL];
        
        [self.imageTarget setImage:sourceImage];
    }
}



















@end
