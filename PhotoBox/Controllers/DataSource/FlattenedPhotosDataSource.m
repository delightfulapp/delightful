//
//  FlattenedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "FlattenedPhotosDataSource.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import "Photo.h"

@interface FlattenedPhotosDataSource ()

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *groupedViewMapping;

@end

@implementation FlattenedPhotosDataSource

- (id)initWithCollectionView:(id)collectionView groupedViewMapping:(DLFYapDatabaseViewAndMapping *)groupedViewMapping {
    self = [super initWithCollectionView:collectionView];
    if (self) {
        self.groupedViewMapping = groupedViewMapping;
        [self setupMapping];
    }
    return self;
}

- (id)initWithCollectionView:(id)collectionView viewMapping:(DLFYapDatabaseViewAndMapping *)viewMapping {
    self = [super initWithCollectionView:collectionView];
    if (self) {
        [self setSelectedViewMapping:viewMapping];
    }
    return self;
}

- (void)setupMapping {
    if (self.groupedViewMapping) {
        DLFYapDatabaseViewAndMapping *viewMapping = [DLFYapDatabaseViewAndMapping ungroupedViewMappingFromViewMapping:self.groupedViewMapping database:self.database];
        
        [self setSelectedViewMapping:viewMapping];
    }
}

@end
