//
//  NPRNotificationManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/20/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRNotificationManager.h"
#import "NPRNotificationView.h"

#import "UIView+Additionals.h"

#define NPR_NOTIFICATION_VIEW_FRAME_HEIGHT 44
#define NPR_NOTIFICATION_ANIMATION_DURATION 0.5
#define NPR_NOTIFICATION_ANIMATION_SPRING_DAMPING 0.7
#define NPR_NOTIFICATION_ANIMATION_INITIAL_SPRING_VELOCITY 0.5

@interface NPRNotificationManager ()

@property (nonatomic, strong) NPRNotificationView *notificationView;
@property (nonatomic, copy) void(^onTapBlock)();
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) NPRNotificationPosition position;
@property (nonatomic, assign) BOOL isShowingNotification;
@property (nonatomic, assign) NSInteger duration;

@end

@implementation NPRNotificationManager

+ (instancetype)sharedManager {
    static NPRNotificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[NPRNotificationManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)postNotificationWithImage:(UIImage *)image position:(NPRNotificationPosition)position type:(NPRNotificationType)type string:(NSString *)string accessoryType:(NPRNotificationAccessoryType)accessoryType accessoryView:(UIView *)accessoryView duration:(NSInteger)duration onTap:(void (^)())onTapBlock {
    [self.notificationView setType:type];
    [self.notificationView setImage:image];
    [self.notificationView setString:string];
    [self.notificationView setAccessoryType:accessoryType];
    [self.notificationView setAccessoryView:accessoryView];
    [self.notificationView setNeedsLayout];
    [self.notificationView layoutIfNeeded];
    
    if (!self.isShowingNotification) {
        [self.notificationView setOrigin:[self startPointForPosition:position]];
    } else {
        if (duration > 0) {
            [self performSelector:@selector(hideNotification) withObject:nil afterDelay:duration inModes:@[NSRunLoopCommonModes]];
        }
    }
    
    
    self.onTapBlock = onTapBlock;
    self.position = position;
    self.duration = duration;
    
    [self showNotificationView:YES position:position];
}

- (void)postLoadingNotificationWithText:(NSString *)text {
    [self postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeNone string:text accessoryType:NPRNotificationAccessoryTypeActivityView accessoryView:nil duration:0 onTap:nil];
}

- (void)postErrorNotificationWithText:(NSString *)text duration:(NSInteger)duration {
    [self postNotificationWithImage:nil position:NPRNotificationPositionBottom type:NPRNotificationTypeError string:text accessoryType:NPRNotificationAccessoryTypeNone accessoryView:nil duration:duration onTap:nil];
}

- (UIWindow *)window {
    return [[[UIApplication sharedApplication] delegate] window];
}

- (NPRNotificationView *)notificationView {
    if (!_notificationView) {
        _notificationView = [[NPRNotificationView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[self window] frame]), NPR_NOTIFICATION_VIEW_FRAME_HEIGHT)];
        [_notificationView setUserInteractionEnabled:YES];
        [_notificationView addGestureRecognizer:self.tapGestureRecognizer];
        [[self window] addSubview:_notificationView];
    }
    return _notificationView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnNotificationView:)];
        [_tapGestureRecognizer setNumberOfTapsRequired:1];
    }
    return _tapGestureRecognizer;
}

- (CGPoint)startPointForPosition:(NPRNotificationPosition)position {
    CGFloat windowHeight = CGRectGetHeight([[self window] frame]);
    CGPoint point;
    switch (position) {
        case NPRNotificationPositionBottom:
            point = CGPointMake(0, windowHeight);
            break;
        case NPRNotificationPositionTop:
            point = CGPointMake(0, - NPR_NOTIFICATION_VIEW_FRAME_HEIGHT);
            break;
        default:
            break;
    }
    return point;
}

- (CGPoint)endPointForPosition:(NPRNotificationPosition)position {
    CGFloat windowHeight = CGRectGetHeight([[self window] frame]);
    CGPoint point;
    switch (position) {
        case NPRNotificationPositionBottom:
            point = CGPointMake(0, windowHeight - NPR_NOTIFICATION_VIEW_FRAME_HEIGHT);
            break;
        case NPRNotificationPositionTop:
            point = CGPointZero;
            break;
        default:
            break;
    }
    return point;
}

- (void)showNotification:(NSArray *)notificationObject {
    [self showNotificationView:[notificationObject[0] boolValue] position:[notificationObject[1] integerValue]];
}

- (void)showNotificationView:(BOOL)show position:(NPRNotificationPosition)position {
    if (show) {
        PBX_LOG(@"Showing notification");
        if (!self.isShowingNotification) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:NPR_NOTIFICATION_ANIMATION_DURATION target:self selector:@selector(executeAnimationWithTimer:) userInfo:@(show) repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
    } else {
        PBX_LOG(@"hide notification");
        if (self.isShowingNotification) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:NPR_NOTIFICATION_ANIMATION_DURATION target:self selector:@selector(executeAnimationWithTimer:) userInfo:@(show) repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)executeAnimationWithTimer:(NSTimer *)timer {
    BOOL showAnimation = [timer.userInfo boolValue];
    id animation = (showAnimation)?[self showAnimation]:[self hideAnimation];
    id completion = (showAnimation)?[self showAnimationCompletion]:[self hideAnimationCompletion];
    [self executeAnimationWithPosition:self.position animation:animation completion:completion];
}

- (void)executeAnimationWithPosition:(NPRNotificationPosition)position animation:(void(^)())animation completion:(void(^)(BOOL))completion {
    [UIView animateWithDuration:NPR_NOTIFICATION_ANIMATION_DURATION delay:0 usingSpringWithDamping:NPR_NOTIFICATION_ANIMATION_SPRING_DAMPING initialSpringVelocity:NPR_NOTIFICATION_ANIMATION_INITIAL_SPRING_VELOCITY options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:animation completion:completion];
}

- (void)hideNotification {
    [self showNotificationView:NO position:self.position];
}

- (id)showAnimation {
    void(^showAnimation)() = ^(){
        self.notificationView.frame = ({
            CGRect frame = self.notificationView.frame;
            frame.origin = [self endPointForPosition:self.position];
            frame;
        });
        self.notificationView.hidden = NO;
    };
    return showAnimation;
}

- (id)showAnimationCompletion {
    return ^(BOOL finished) {
        self.isShowingNotification = YES;
        if (self.duration > 0) {
            [self performSelector:@selector(showNotification:) withObject:@[@(NO), @(self.position)] afterDelay:self.duration inModes:@[NSRunLoopCommonModes]];
        }
    };
}

- (id)hideAnimation {
    return ^{
        self.notificationView.frame = ({
            CGRect frame = self.notificationView.frame;
            frame.origin = [self startPointForPosition:self.position];
            frame;
        });
    };
}

- (id)hideAnimationCompletion {
    return ^(BOOL finished) {
        self.isShowingNotification = NO;
        [self.notificationView setHidden:YES];
    };
}

#pragma mark - Gesture

- (void)tapOnNotificationView:(UITapGestureRecognizer *)tapGesture {
    if (self.onTapBlock) {
        self.onTapBlock();
    }
    if (self.duration > 0) {
        [self hideNotification];
    }
}

@end
