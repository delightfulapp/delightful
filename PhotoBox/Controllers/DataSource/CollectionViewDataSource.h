//
//  CollectionViewDataSource.h
//  Expiry
//
//  Created by Nico Prananta on 7/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectionViewCellConfigureBlock)(id cell, id item);

@interface CollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) CollectionViewCellConfigureBlock configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfItem:(id)item;

@end
