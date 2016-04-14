//
//  CXMovieWriter.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface CXMovieWriter : NSObject

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
                        audioSettings:(NSDictionary *)audioSettings
                        dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;    // 实时采样

- (void)startWriting;
- (void)stopWriting;


@end
