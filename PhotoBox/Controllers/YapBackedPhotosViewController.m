//
//  YapBackedPhotosViewController.m
//  Delightful
//
//  Created by  on 11/8/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapBackedPhotosViewController.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "GroupedPhotosDataSource.h"

#import "DLFDatabaseManager.h"

#import "PhotosCollection.h"

#import "SyncEngine.h"

#import "Photo.h"

@interface YapBackedPhotosViewController ()

@end

@implementation YapBackedPhotosViewController

- (void)refresh {
    NSLog(@"Refresh in %@", self.item?:@"all photos");
    
    if (self.item) {
        [[SyncEngine sharedEngine] pauseSyncingPhotos:YES collection:self.item.itemId];
        
        DLFYapDatabaseViewAndMapping *flattenedMapping = [((GroupedPhotosDataSource *)self.dataSource) selectedFlattenedViewMapping];
        NSString *flattenedView = flattenedMapping.viewName;
        [[DLFDatabaseManager manager] removePhotosInFlattenedView:flattenedView completion:^{
            NSLog(@"Photos in %@ removed", self.item.itemId);
            
            [self.refreshControl endRefreshing];
            [[SyncEngine sharedEngine] refreshPhotosInCollection:self.item.itemId collectionType:self.item.class sort:self.currentSort];
        }];
    } else {
        [[SyncEngine sharedEngine] setPausePhotosSync:YES];
        
        [[DLFDatabaseManager manager] removeAllPhotosWithCompletion:^{
            NSLog(@"Removed all photos");
            
            [self.refreshControl endRefreshing];
            [[SyncEngine sharedEngine] refreshResource:NSStringFromClass(Photo.class)];
        }];
    }
}

@end
