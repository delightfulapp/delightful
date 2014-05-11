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
#import "PhotoBoxFetchedResultsController.h"

extern NSString *const galleryContainerType;

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
@property (nonatomic, strong) NSString *displayedItemIdKey;
@property (nonatomic, strong) NSString *relationshipKeyPathWithItem;
@property (nonatomic, strong, readonly) NSString *cellIdentifier;
@property (nonatomic, strong, readonly) NSString *sectionHeaderIdentifier;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) BOOL disableFetchOnLoad;
@property (nonatomic, assign) int numberOfColumns;
@property (nonatomic, strong) NSString *fetchedInIdentifier;

@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int totalItems;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int currentRow;
@property (nonatomic, assign, readonly) int pageSize;

@property (nonatomic, strong) UILabel *navigationTitleLabel;

@property (nonatomic) CollectionViewDataSource *dataSource;

- (Class)dataSourceClass;
- (void)refresh;
- (void)showError:(NSError *)error;
- (CollectionViewCellConfigureBlock)cellConfigureBlock;
- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock;
- (void)didFetchItems;
- (void)setupDataSourceConfigureBlock;
- (void)setTitle:(NSString *)title subtitle:(NSString *)sub;
- (void)didChangeNumberOfColumns;

- (BOOL)isGallery ;
@end
