//
//  CXImageTransport.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CXImageTransport <NSObject>

- (void)setImage:(CIImage *)image;

@end

