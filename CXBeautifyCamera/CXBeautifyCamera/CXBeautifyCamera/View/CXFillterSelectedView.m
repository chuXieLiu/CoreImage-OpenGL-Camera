//
//  CXFillterSelectedView.m
//  CXBeautifyCamera
//
//  Created by c_xie on 16/4/13.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXFillterSelectedView.h"
#import "CXPhotoFilter.h"
#import "UIView+CXExtension.h"
#import "CXCameraNotification.h"

static CGFloat const kCXButtonMargin = 10.0f;

@interface CXFillterSelectedView ()
<
    UIScrollViewDelegate
>

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIButton *leftButton;
@property (weak, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) NSMutableArray *labels;
@property (nonatomic,strong) NSArray *filterNames;

@end

@implementation CXFillterSelectedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [leftButton setImage:[UIImage imageNamed:@"left_arrow"]
                    forState:UIControlStateNormal];
        [leftButton addTarget:self
                       action:@selector(pageLeft:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        self.leftButton = leftButton;
        self.leftButton.enabled = NO;
        
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [rightButton setImage:[UIImage imageNamed:@"right_arrow"]
                     forState:UIControlStateNormal];
        [rightButton addTarget:self
                        action:@selector(pageRight:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightButton];
        self.rightButton = rightButton;
        
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        NSArray *filterNames = [CXPhotoFilter filterDisplayNames];
        
        self.labels = @[].mutableCopy;
        for (NSString *text in filterNames) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:16.0f];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = text;
            [self.scrollView addSubview:label];
            [self.labels addObject:label];
        }
        
        self.filterNames = [CXPhotoFilter filterNames];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftButton.left = kCXButtonMargin;
    self.leftButton.top = 0;
    self.leftButton.size = CGSizeMake(self.height, self.height);
    
    self.rightButton.right = self.width - kCXButtonMargin;
    self.rightButton.top = 0;
    self.rightButton.size = self.leftButton.size;
    
    self.scrollView.left = self.leftButton.right;
    self.scrollView.top = 0;
    self.scrollView.width = self.rightButton.left - self.leftButton.right;
    self.scrollView.height = self.height;
    
    for (NSInteger i = 0; i < self.labels.count; i ++) {
        UILabel *label = self.labels[i];
        label.width = self.scrollView.width;
        label.height = self.scrollView.height;
        label.top = 0;
        label.left = i * self.scrollView.width;
    }
    
    CGFloat contentWidth = self.labels.count * self.scrollView.width;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.scrollView.height);
}


- (void)pageLeft:(id)sender {
    
    NSInteger currentIndex = [self currentIndex];
    if (currentIndex > 0) {
        CGRect frame = [self.labels[currentIndex] frame];
        frame.origin.x -= self.scrollView.width;
        [self.scrollView scrollRectToVisible:frame animated:YES];
        self.rightButton.enabled = YES;
        [self postFilterDidChangeNoteWithIndex:currentIndex - 1];
    }
    
    self.leftButton.enabled = currentIndex - 1 > 0;

}


- (void)pageRight:(id)sender {
    NSInteger currentIndex = [self currentIndex];
    if (currentIndex < self.labels.count - 1) {
        CGRect frame = [self.labels[currentIndex] frame];
        frame.origin.x += self.scrollView.width;
        [self.scrollView scrollRectToVisible:frame animated:YES];
        self.leftButton.enabled = YES;
        [self postFilterDidChangeNoteWithIndex:currentIndex + 1];
    }
    
    self.rightButton.enabled = currentIndex + 1 < self.labels.count - 1;
    
}

- (NSInteger)currentIndex
{
    return self.scrollView.contentOffset.x / self.scrollView.width;
}

- (void)postFilterDidChangeNoteWithIndex:(NSInteger)index
{
    NSString *filterName = self.filterNames[index];
    CIFilter *filter = [CXPhotoFilter filterWithName:filterName];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCXCameraFitlerDidChangeNotification object:filter userInfo:nil];
}


@end
