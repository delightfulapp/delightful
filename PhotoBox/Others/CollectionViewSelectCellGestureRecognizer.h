//
//  CollectionViewSelectCellGestureRecognizer.h
//  PhotoBox
//
//  Created by Nico Prananta on 11/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionViewSelectCellGestureRecognizer : NSObject

/**
 *  The collection view to apply the gesture.
 */
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

/**
 *  Set to NO to tell CollectionViewSelectCellGestureRecognizer to stop recognizing gesture. Default is YES.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enable;

/**
 *  Returns YES if there is at least one cell being selected.
 */
@property (nonatomic, assign, readonly, getter = isSelecting) BOOL selecting;

/**
 *  Array of currently selected index paths.
 */
@property (nonatomic, copy, readonly) NSMutableArray *selectedIndexPaths;


/**
 *  Initiate gesture using the specified collection view
 *
 *  @param collectionView Collection view to apply the gesture to
 *
 *  @return CollectionViewSelectCellGestureRecognizer instance
 */
- (id)initWithCollectionView:(UICollectionView *)collectionView;

/**
 *  Cancel or deselect selected cells
 */
- (void)cancelSelection;

@end
