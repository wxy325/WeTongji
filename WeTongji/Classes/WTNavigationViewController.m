//
//  WTNavigationViewController.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-14.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "WTNavigationViewController.h"
#import "NSUserDefaults+Addition.h"
#import "NSNotificationCenter+Addition.h"

@interface WTNavigationViewController ()

@end

@implementation WTNavigationViewController

@synthesize navBarShadowImageView = _navBarShadowImageView;
@synthesize bgImageView = _bgImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self configureBgImageView];
}

- (void)viewDidUnload {
    self.navBarShadowImageView = nil;
    self.bgImageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter registerChangeCurrentUIStyleNotificationWithSelector:@selector(handleChangeCurrentUIStyleNotification:) target:self];
    
    [self handleChangeCurrentUIStyleNotification:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark UI methods

- (void)configureBgImageView {
    UIStyle style = [NSUserDefaults getCurrentUIStyle];
    if(style == UIStyleBlackChocolate){
        self.bgImageView.image = [UIImage imageNamed:@"main_bg.png"];
    } else if(style == UIStyleWhiteChocolate) {
        self.bgImageView.image = [UIImage imageNamed:@"main_bg_white.png"];
    }
}

#pragma mark -
#pragma mark Handle notifications

- (void)handleChangeCurrentUIStyleNotification:(NSNotification *)notification {
    [self configureBgImageView];
}

@end
