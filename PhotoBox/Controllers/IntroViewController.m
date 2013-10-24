//
//  IntroViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "IntroViewController.h"

#import <MYBlurIntroductionView.h>

#import "PanelFactory.h"

@interface IntroViewController () <MYIntroductionDelegate>

@property (nonatomic, strong) MYBlurIntroductionView *introductionView;

@end

@implementation IntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    self.introductionView.BackgroundImageView.image = [PanelFactory imageBackgroundForVersion:version];
    [self.introductionView buildIntroductionWithPanels:[PanelFactory panelsForVersion:version]];
    [self.introductionView.BlurView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

- (MYBlurIntroductionView *)introductionView {
    if (!_introductionView) {
        _introductionView = [[MYBlurIntroductionView alloc] initWithFrame:self.view.bounds];
        _introductionView.delegate = self;
        [self.view addSubview:self.introductionView];
    }
    return _introductionView;
}

#pragma mark - Introductions delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex {
    
}

@end
