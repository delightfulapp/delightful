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
    CLS_LOG(@"Refresh in %@", self.item?self.item.itemId:@"all photos");
    
    [(GroupedPhotosDataSource *)self.dataSource setPause:YES];
    [[SyncEngine sharedEngine] pauseSyncingPhotos:YES collection:(self.item?self.item.itemId:nil)];
    
    void (^photosRemovalCompletion)() = ^void() {
        CLS_LOG(@"Photos in %@ removed", self.item.itemId);
        [((GroupedPhotosDataSource *)self.dataSource).mainConnection beginLongLivedReadTransaction];
        [((GroupedPhotosDataSource *)self.dataSource).mainConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [((GroupedPhotosDataSource *)self.dataSource).selectedViewMapping.mapping updateWithTransaction:transaction];
        }];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CLS_LOG(@"refreshing now");
            [(GroupedPhotosDataSource *)self.dataSource setPause:NO];
            [[SyncEngine sharedEngine] refreshPhotosInCollection:(self.item?self.item.itemId:nil) collectionType:(self.item?self.item.class:nil) sort:self.currentSort];
        });
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
