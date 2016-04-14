//
//  CXPreviewView.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXPreviewView.h"

@interface CXPreviewView ()

@property (nonatomic,assign) CGRect drawableBounds;

@end

@implementation CXPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    self = [super initWithFrame:frame context:context];
    
    if (self) {
        
        self.enableSetNeedsDisplay = NO;
        
        self.backgroundColor = [UIColor blackColor];
        
        self.opaque = YES;
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.frame = frame;
        
        [self bindDrawable];
        
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
        
    }
    
    return self;
}


- (void)setImage:(CIImage *)sourceImage
{
    // 绑定上下文
    
    [self bindDrawable];
    
    // 为滤镜设置图片
    
    [self.filter setValue:sourceImage forKey:kCIInputImageKey];
    
    // 合成图片
    
    CIImage *filteredImage = self.filter.outputImage;
    
    if (filteredImage) {
        
        CGRect rect = CXCenterCropImageRect(filteredImage.extent, self.drawableBounds);
        
        [self.coreImageContext drawImage:filteredImage
                                  inRect:self.drawableBounds
                                fromRect:rect];
    }
    
    // 开始绘制
    
    [self display];
    
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

CGRect CXCenterCropImageRect(CGRect sourceRect , CGRect previewRect) {
    
    // 宽高比
    
    CGFloat sourceAspectRatio = sourceRect.size.width / sourceRect.size.height;
    
    CGFloat previewAspectRatio = previewRect.size.width / previewRect.size.height;
    
    CGRect drawRect = sourceRect;
    
    if (sourceAspectRatio > previewAspectRatio) {
        // sourceRect的height相对比较小，以height为基准
        CGFloat scaleWidth = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width - scaleWidth) * 0.5;
        drawRect.size.width = scaleWidth;
    } else {
        // sourceRect的width相对比较小， 以width为基准
        CGFloat scaleHeight = drawRect.size.width / previewAspectRatio;
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) * 0.5;
        drawRect.size.height = scaleHeight;
    }
    return drawRect;
}







@end
