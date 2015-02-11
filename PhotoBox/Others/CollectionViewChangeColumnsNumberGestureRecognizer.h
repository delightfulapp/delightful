//
//  CollectionViewChangeColumnsNumberGestureRecognizer.h
//  Delightful
//
//  Created by  on 2/11/15.
//  Copyright (c) 2015 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionViewChangeColumnsNumberGestureRecognizerDelegate <NSObject>

- (void)didChangeNumberOfColumns:(NSInteger)newNumberOfColumns;

@end

@interface CollectionViewChangeColumnsNumberGestureRecognizer : NSObject

/**
 *  The collection view to apply the gesture.
 */
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

/**
 *  Set to NO to tell CollectionViewChangeColumnsNumberGestureRecognizer to stop recognizing gesture. Default is YES.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enableGesture;

/**
 *  Delegate for this object
 */
@property (nonatomic, weak) id<CollectionViewChangeColumnsNumberGestureRecognizerDelegate> delegate;

/**
 *  Initiate gesture using the specified collection view
 *
 *  @param collectionView Collection view to apply the gesture to
 *
 *  @return CollectionViewSelectCellGestureRecognizer instance
 */
- (id)initWithCollectionView:(UICollectionView *)collectionView numberOfColumnsKey:(NSString *)numberOfColumnsKey;

@end
