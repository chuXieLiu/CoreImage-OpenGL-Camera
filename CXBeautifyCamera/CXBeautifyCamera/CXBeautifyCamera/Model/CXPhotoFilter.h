//
//  CXPhotoFilter.h
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CXPhotoFilter : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)defaultFilter;
+ (CIFilter *)filterWithName:(NSString *)filterName;


@end
