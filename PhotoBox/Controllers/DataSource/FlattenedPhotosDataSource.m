//
//  FlattenedPhotosDataSource.m
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
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

- (void)setupMapping {
    [DLFYapDatabaseViewAndMapping asyncUngroupedViewMappingFromViewMapping:self.groupedViewMapping database:self.database completion:^(DLFYapDatabaseViewAndMapping *viewMapping) {
        [self setSelectedViewMapping:viewMapping];
    }];
}

@end
