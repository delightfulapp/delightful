//
//  SharePanel.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "SharePanel.h"

#import "SeeThroughCircleView.h"

#import "SharerManager.h"

typedef NS_ENUM(NSInteger, SharePanelServiceType) {
    SharePanelServiceTypeSMS = 1000,
    SharePanelServiceTypeEmail,
    SharePanelServiceTypeFacebook,
    SharePanelServiceTypeTwitter
};

@implementation SharePanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)panelDidAppear {
    NSLog(@"Panel did appear");
    for (int i=SharePanelServiceTypeSMS; i<SharePanelServiceTypeTwitter+1; i++) {
        SeeThroughCircleView *see = (SeeThroughCircleView *)[self buttonForService:i];
        see.frame = ({
            CGRect frame = see.frame;
            int j = i-1000;
            frame.origin.x = j*50+CGRectGetMinX(self.PanelDescriptionLabel.frame)+j*10;
            frame.origin.y = CGRectGetMaxY(self.PanelDescriptionLabel.frame) + 40;
            frame;
        });
        see.alpha = 0;
        [self addSubview:see];
    }
    
    [UIView animateWithDuration:0.5 delay:1 options:0 animations:^{
        for (int i=SharePanelServiceTypeSMS; i<SharePanelServiceTypeTwitter+1; i++) {
            SeeThroughCircleView *see = (SeeThroughCircleView *)[self buttonForService:i];
            see.alpha = 1;
        }
    } completion:nil];
}

- (void)panelDidDisappear {
    NSLog(@"panel did disappear");
    [UIView animateWithDuration:0.5 animations:^{
        for (int i=SharePanelServiceTypeSMS; i<SharePanelServiceTypeTwitter+1; i++) {
            SeeThroughCircleView *see = (SeeThroughCircleView *)[self buttonForService:i];
            see.alpha = 0;
        }
    }];
}

- (UIView *)buttonForService:(SharePanelServiceType)type {
    SeeThroughCircleView *seeView = (SeeThroughCircleView *)[self viewWithTag:type];
    if (!seeView) {
        seeView = [[SeeThroughCircleView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [seeView setText:[self stringForService:type]];
        [seeView setFontSize:20];
        [seeView setFontName:@"shareicons"];
        [seeView setBackgroundColor:[UIColor clearColor]];
        [seeView setTag:type];
        [seeView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(serviceTapped:)];
        [seeView addGestureRecognizer:tap];
    }
    
    return seeView;
}

- (NSString *)stringForService:(SharePanelServiceType)type {
    NSString *shareIconText;
    switch (type) {
        case SharePanelServiceTypeEmail:
            shareIconText = @"\ue600";
            break;
        case SharePanelServiceTypeFacebook:
            shareIconText = @"\ue603";
            break;
        case SharePanelServiceTypeSMS:
            shareIconText = @"\ue601";
            break;
        case SharePanelServiceTypeTwitter:
            shareIconText = @"\ue602";
            break;
        default:
            break;
    }
    return shareIconText;
}

- (void)serviceTapped:(UITapGestureRecognizer *)gesture {
    NSLog(@"here?");
    SeeThroughCircleView *see = (SeeThroughCircleView *)gesture.view;
    NSInteger type = see.tag;
    ShareType shareType = 0;
    NSURL *URL = [NSURL URLWithString:PHOTOBOX_TESTFLIGHT_BETA_URL];
    NSString *text = [NSString stringWithFormat:@"%@\n%@", PHOTOBOX_SHARE_TEXT, PHOTOBOX_TESTFLIGHT_BETA_URL];
    
    switch (type) {
        case SharePanelServiceTypeEmail:
            shareType = ShareTypeEmail;
            break;
        case SharePanelServiceTypeFacebook:
            shareType = ShareTypeFacebook;
            break;
        case SharePanelServiceTypeSMS:
            shareType = ShareTypeSMS;
            break;
        case SharePanelServiceTypeTwitter:
            shareType = ShareTypeTwitter;
            text = [NSString stringWithFormat:@"%@\n%@", PHOTOBOX_SHARE_TWEET, PHOTOBOX_TESTFLIGHT_BETA_URL];
            break;
        default:
            break;
    }
    
    [SharerManager shareTo:shareType URL:URL text:text subject:PHOTOBOX_SHARE_SUBJECT];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
