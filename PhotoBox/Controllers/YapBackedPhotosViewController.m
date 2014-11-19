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
    NSLog(@"Refresh in %@", self.item?self.item.itemId:@"all photos");
    
    [[SyncEngine sharedEngine] pauseSyncingPhotos:YES collection:(self.item?self.item.itemId:nil)];
    
    void (^photosRemovalCompletion)() = ^void() {
        NSLog(@"Photos in %@ removed", self.item.itemId);
        
        [self.refreshControl endRefreshing];
        [[SyncEngine sharedEngine] refreshPhotosInCollection:(self.item?self.item.itemId:nil) collectionType:(self.item?self.item.class:nil) sort:self.currentSort];
    };

    if (self.item) {
        DLFYapDatabaseViewAndMapping *flattenedMapping = [((GroupedPhotosDataSource *)self.dataSource) selectedFlattenedViewMapping];
        NSString *flattenedView = flattenedMapping.viewName;
        [[DLFDatabaseManager manager] removePhotosInFlattenedView:flattenedView completion:photosRemovalCompletion];
    } else {
        [[DLFDatabaseManager manager] removeAllPhotosWithCompletion:photosRemovalCompletion];
    }
}

@end
