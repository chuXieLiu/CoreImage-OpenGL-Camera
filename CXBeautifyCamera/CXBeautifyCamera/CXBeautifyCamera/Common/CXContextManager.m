//
//  CXContextManager.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXContextManager.h"

static CXContextManager *instance;

@implementation CXContextManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 使用OpenGLES2这个版本的api
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        NSDictionary *options = @{
                                  kCIContextWorkingColorSpace : [NSNull null]
                                  };
        
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:options];
    }
    return self;
}






@end
