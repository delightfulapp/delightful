//
//  NPRNotificationManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/20/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NPRNotificationType) {
    NPRNotificationTypeNone,
    NPRNotificationTypeSuccess,
    NPRNotificationTypeError,
    NPRNotificationTypeWarning
};

typedef NS_ENUM(NSInteger, NPRNotificationAccessoryType) {
    NPRNotificationAccessoryTypeNone,
    NPRNotificationAccessoryTypeActivityView,
    NPRNotificationAccessoryTypeCloseButton,
};

typedef NS_ENUM(NSInteger, NPRNotificationPosition) {
    NPRNotificationPositionTop,
    NPRNotificationPositionBottom
};

@interface NPRNotificationManager : NSObject

+ (instancetype)sharedManager;

- (void)postNotificationWithImage:(UIImage *)image
                        position:(NPRNotificationPosition)position
                            type:(NPRNotificationType)type
                          string:(id)string
                   accessoryType:(NPRNotificationAccessoryType)accessoryType
                   accessoryView:(UIView *)view
                        duration:(NSInteger)duration
                           onTap:(void(^)())onTapBlock;

- (void)postLoadingNotificationWithText:(NSString *)text;
- (void)postErrorNotificationWithText:(NSString *)text duration:(NSInteger)duration;

- (void)hideNotification;

@end
