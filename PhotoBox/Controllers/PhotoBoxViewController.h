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

typedef NS_ENUM(NSUInteger, PinchDirection) {
    PinchIn,
    PinchOut
};

@class PhotoBoxModel;

@interface PhotoBoxViewController : UICollectionViewController

@property (nonatomic, strong) PhotoBoxModel *item;
@property (nonatomic, assign) ResourceType resourceType;
@property (nonatomic, strong) Class resourceClass;
@property (nonatomic, strong) NSString *resourceId;
@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) int numberOfColumns;

@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int totalItems;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int currentRow;

@property (nonatomic, strong) UILabel *navigationTitleLabel;

@property (nonatomic) CollectionViewDataSource *dataSource;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

- (void)refresh;
- (void)showError:(NSError *)error;
- (CollectionViewCellConfigureBlock)cellConfigureBlock;
- (void)didFetchItems;
- (void)setupDataSource;
- (void)setupDataSourceConfigureBlock;
- (void)setTitle:(NSString *)title subtitle:(NSString *)sub;
@end
