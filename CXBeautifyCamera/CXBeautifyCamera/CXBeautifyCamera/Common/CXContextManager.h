//
//  CXContextManager.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface CXContextManager : NSObject

+ (instancetype)sharedManager;

// GL绘图上下文
@property (nonatomic,strong) EAGLContext *eaglContext;
// coreImage工作上下文
@property (nonatomic,strong) CIContext *ciContext;

@end
