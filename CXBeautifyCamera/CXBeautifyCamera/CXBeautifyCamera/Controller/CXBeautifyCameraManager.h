//
//  CXBeautifyCameraManager.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXImageTransport.h"

@interface CXBeautifyCameraManager : NSObject

- (void)setupCaptureSession;
- (void)startCaptureSession;
- (void)stopCaptureSession;

- (void)startRecorded;
- (void)stopRecorded;

@property (nonatomic,assign,readonly) bool isRecorded;

// 串行队列
@property (nonatomic,strong,readonly) dispatch_queue_t captureQueue;

@property (nonatomic,weak) id<CXImageTransport> imageTarget;


@end
