//
//  ViewController.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/12.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXBeautifyCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (IBAction)takePhoto:(id)sender {
    
    
    
}


- (IBAction)record:(id)sender {
    
    CXBeautifyCameraViewController *cameraVC = [[CXBeautifyCameraViewController alloc] init];
    [self presentViewController:cameraVC animated:YES completion:nil];
}

@end
