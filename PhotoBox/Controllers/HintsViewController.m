//
//  HintsViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/14/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "HintsViewController.h"

@interface HintsViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *hints;

@end

@implementation HintsViewController

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
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setBounces:YES];
    [self.scrollView setAlwaysBounceVertical:NO];
    [self.scrollView setDelegate:self];
    
    
    
    self.pageControl = [[UIPageControl alloc] init];
    [self.view addSubview:self.pageControl];
    
    
    
    self.title = NSLocalizedString(@"Gestures", nil);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.scrollView setFrame:self.view.bounds];
    
    NSArray *hints = @[@"HintPinch", @"Hint-CloseInfo"];
    self.hints = hints;
    int i = 0;
    for (NSString *hint in hints) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:hint owner:nil options:nil] firstObject];
        view.frame = ({
            CGRect frame = view.frame;
            frame.origin.x = i * CGRectGetWidth(self.scrollView.frame);
            frame.origin.y = 0;
            frame.size.width = CGRectGetWidth(self.scrollView.frame);
            frame.size.height = CGRectGetHeight(self.scrollView.frame);
            frame;
        });
        [self.scrollView addSubview:view];
        i++;
    }
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame)*hints.count, CGRectGetHeight(self.scrollView.frame))];
    
    [self.pageControl setNumberOfPages:hints.count];
    [self.pageControl sizeToFit];
    [self.pageControl setCenter:CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame))];
    [self.pageControl setFrame:CGRectOffset(self.pageControl.frame, 0, -CGRectGetHeight(self.pageControl.frame)/2)];
    
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [self.view addSubview:closeButton];
    closeButton.frame = ({
        CGRect frame = closeButton.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame) - CGRectGetWidth(frame) -10;
        frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - 10;
        frame;
    });
    closeButton.center = CGPointMake(closeButton.center.x, self.pageControl.center.y);
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floorf(scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.frame));
    [self.pageControl setCurrentPage:page];
}

- (void)closeButtonDidTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
