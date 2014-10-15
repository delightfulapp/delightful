//
//  SyncEngine.h
//  Delightful
//
//  Created by  on 10/13/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SyncEngineWillStartFetchingNotification;
extern NSString *const SyncEngineDidFinishFetchingNotification;
extern NSString *const SyncEngineDidFailFetchingNotification;

extern NSString *const SyncEngineNotificationResourceKey;
extern NSString *const SyncEngineNotificationPageKey;
extern NSString *const SyncEngineNotificationErrorKey;
extern NSString *const SyncEngineNotificationCountKey;

@interface SyncEngine : NSObject

+ (instancetype)sharedEngine;

- (void)startSyncing;

@property (nonatomic, assign, readonly) BOOL isSyncing;

@property (nonatomic, assign) BOOL pauseSync;

@end
