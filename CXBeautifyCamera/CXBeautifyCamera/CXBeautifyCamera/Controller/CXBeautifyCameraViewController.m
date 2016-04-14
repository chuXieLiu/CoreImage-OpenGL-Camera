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
#import "CXVideoEditView.h"

@interface CXBeautifyCameraViewController ()

@property (nonatomic,strong) CXBeautifyCameraManager *cameraManager;

@property (nonatomic,weak) CXPreviewView *previewView;

@property (nonatomic,weak) CXShutterButton *shutterButton;

@property (nonatomic,weak) CXVideoEditView *videoEditView;

@property (nonatomic,weak) UIActivityIndicatorView *indicator;

@end

@implementation CXBeautifyCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPreviewView];
    
    [self setupOverlayView];
    
    [self setupCameraManager];
    
    [self addNotificationObserver];
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

- (BOOL)prefersStatusBarHidden
{
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
        self.shutterButton.enabled = NO;
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

- (void)videoWillWrite:(NSNotification *)note
{
    if (!_indicator) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        indicator.layer.cornerRadius = 6.0;
        indicator.layer.masksToBounds = YES;
        [self.view addSubview:indicator];
        
        CGFloat width = 80;
        CGFloat height = 80;
        CGFloat x = (self.view.frame.size.width - width) * 0.5;
        CGFloat y = (self.view.frame.size.height - height) * 0.5;
        
        indicator.frame = CGRectMake(x, y, width, height);
        
        self.indicator = indicator;
    }
    
    [self.indicator startAnimating];
}

- (void)videoDidWrite:(NSNotification *)note
{
    [self.indicator stopAnimating];
    NSURL *fileURL = note.object;
    __weak typeof(self) weakSelf = self;
    CXVideoEditView *videoEditView = [CXVideoEditView videoEditViewWithVideoURL:fileURL recordAgainBlock:^{
        weakSelf.shutterButton.enabled = YES;
        [weakSelf.videoEditView removeFromSuperview];
    } employVideoBlock:^{
        weakSelf.shutterButton.enabled = YES;
        [weakSelf.videoEditView removeFromSuperview];
    }];
    [self.view addSubview:videoEditView];
    videoEditView.frame = self.view.bounds;
    self.videoEditView = videoEditView;
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
    self.view.backgroundColor = [UIColor blackColor];
    
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
    self.shutterButton = shutterButton;
    
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


- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDidChange:) name:kCXCameraFitlerDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoWillWrite:) name:KCXCameraWillWriteVideoNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidWrite:) name:KCXCameraWriteVideoCompletionNotification object:nil];
}




@end
