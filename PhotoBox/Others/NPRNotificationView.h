//
//  NPRNotificationView.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/20/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NPRNotificationManager.h"

@interface NPRNotificationView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *accessoryView;

- (void)setType:(NPRNotificationType)type;
- (void)setString:(id)string;
- (void)setAccessoryType:(NPRNotificationAccessoryType)accessoryType;

@end
