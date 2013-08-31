//
//  PhotoBoxViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoBoxClient.h"

#import "CollectionViewDataSource.h"

@interface PhotoBoxViewController : UICollectionViewController

@property (nonatomic, assign) ResourceType resourceType;
@property (nonatomic, strong) NSString *resourceId;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isFetching;

@property (nonatomic) CollectionViewDataSource *dataSource;

- (void)refresh;
- (void)showError:(NSError *)error;
- (CollectionViewCellConfigureBlock)cellConfigureBlock;
@end
