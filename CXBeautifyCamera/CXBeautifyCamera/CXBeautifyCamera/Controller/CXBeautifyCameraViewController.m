//
//  CXBeautifyCameraViewController.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXBeautifyCameraViewController.h"
#import "CXBeautifyCameraManager.h"
#import "CXContextManager.h"
#import "CXPreviewView.h"
#import "CXPhotoFilter.h"
#import "UIView+CXExtension.h"
#import "CXShutterButton.h"
#import "CXFillterSelectedView.h"
#import "CXCameraNotification.h"

@interface CXBeautifyCameraViewController ()

@property (nonatomic,strong) CXBeautifyCameraManager *cameraManager;

@property (nonatomic,weak) CXPreviewView *previewView;

@end

@implementation CXBeautifyCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPreviewView];
    
    [self setupOverlayView];
    
    [self setupCameraManager];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDidChange:) name:kCXCameraFitlerDidChangeNotification object:nil];
}

- (void)dealloc
{
    [self.cameraManager stopCaptureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - target event

- (void)shutter:(CXShutterButton *)shutterButton
{
    shutterButton.selected = !shutterButton.isSelected;
    
    if (shutterButton.isSelected) {
        [self.cameraManager startRecorded];
    } else {
        [self.cameraManager stopRecorded];
    }
}

- (void)cancel:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)filterDidChange:(NSNotification *)note
{
    CIFilter *filter = note.object;
    self.previewView.filter = filter;
}

#pragma mark - private method

- (void)setupPreviewView
{
    CXPreviewView *previewView = [[CXPreviewView alloc] initWithFrame:self.view.bounds context:[CXContextManager sharedManager].eaglContext];
    previewView.filter = [CXPhotoFilter defaultFilter];
    previewView.coreImageContext = [CXContextManager sharedManager].ciContext;
    [self.view addSubview:previewView];
    self.previewView = previewView;
}

- (void)setupCameraManager
{
    self.cameraManager = [[CXBeautifyCameraManager alloc] init];
    self.cameraManager.imageTarget = self.previewView;
    [self.cameraManager setupCaptureSession];
    [self.cameraManager startCaptureSession];
}

- (void)setupOverlayView
{
    CGFloat modeViewHeight = 100;
    CGRect modeViewFrame = CGRectMake(0, self.view.height - modeViewHeight, self.view.width, modeViewHeight);
    UIView *modeView = [[UIView alloc] initWithFrame:modeViewFrame];
    modeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:modeView];
    
    
    CXShutterButton *shutterButton = [[CXShutterButton alloc] initWithMode:CXShutterButtonModeVideo];
    [shutterButton addTarget:self
                      action:@selector(shutter:)
            forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:shutterButton];
    CGFloat width = 68.0f;
    CGFloat height = width;
    shutterButton.size = CGSizeMake(width, height);
    shutterButton.centerX = modeView.width * 0.5;
    shutterButton.bottom = modeView.height - 10.0f;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [cancelButton addTarget:self
                     action:@selector(cancel:)
           forControlEvents:UIControlEventTouchUpInside];
    [modeView addSubview:cancelButton];
    [cancelButton sizeToFit];
    cancelButton.centerY = shutterButton.centerY;
    cancelButton.left = 10.0f;
    
    CGRect selectedViewFrame = CGRectMake(0.f, 0.f, self.view.width, 44.0f);
    CXFillterSelectedView *fillterView = [[CXFillterSelectedView alloc] initWithFrame:selectedViewFrame];
    fillterView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:fillterView];
    
}





@end
