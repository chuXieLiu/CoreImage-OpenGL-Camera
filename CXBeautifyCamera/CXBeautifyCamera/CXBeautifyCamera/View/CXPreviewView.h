//
//  CXPreviewView.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "CXImageTransport.h"

@interface CXPreviewView : GLKView <CXImageTransport>

/**
 * 当前滤镜
 */
@property (nonatomic,strong) CIFilter *filter;
/**
 *  coreImage绘制的上下文
 */
@property (nonatomic,strong) CIContext *coreImageContext;



@end
