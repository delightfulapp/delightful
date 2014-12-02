//
//  PhotosSubsetViewController.m
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosSubsetViewController.h"

#import "PhotosSubsetDataSource.h"

#import "SyncEngine.h"

#import "PhotosCollection.h"

#import "SortTableViewController.h"

@interface PhotosSubsetViewController ()

@property (nonatomic, assign) BOOL viewJustDidLoad;

@end

@implementation PhotosSubsetViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewJustDidLoad = YES;
    
    self.title = self.item.titleName;
}

- (void)viewDidAppear:(BOOL)animated {
    [self setRegisterSyncingNotification:YES];
    [((YapDataSource *)self.dataSource) setPause:NO];
    if (self.viewJustDidLoad) {
        self.viewJustDidLoad = NO;
        [((PhotosSubsetDataSource *)self.dataSource) setFilterName:self.filterName objectKey:self.objectKey filterKey:self.item.itemId];
        [[SyncEngine sharedEngine] startSyncingPhotosInCollection:self.item.itemId collectionType:self.item.class sort:dateUploadedDescSortKey];
    } else {
        [[SyncEngine sharedEngine] pauseSyncingPhotos:NO collection:self.item.itemId];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"view will disappear");
    [self setRegisterSyncingNotification:NO];
    [((YapDataSource *)self.dataSource) setPause:YES];
    [[SyncEngine sharedEngine] pauseSyncingPhotos:YES collection:self.item.itemId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [PhotosSubsetDataSource class];
}


- (void)willStartSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        NSLog(@"will start syncing");
        [self setIsFetching:YES];
        self.isDoneSyncing = NO;
    }
}

- (void)didFinishSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if (![item isKindOfClass:[NSNull class]] && [resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        NSLog(@"did finish syncing");
        NSNumber *count = userInfo[SyncEngineNotificationCountKey];
        if (count.intValue == 0) {
            NSLog(@"fetched 0 photos");
            [self setIsFetching:NO];
            
            self.isDoneSyncing = YES;
        }
    }
}

- (void)didFailSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    NSString *item = userInfo[SyncEngineNotificationIdentifierKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])] && [item isEqualToString:self.item.itemId]) {
        [self setIsFetching:NO];
    }
}

@end
