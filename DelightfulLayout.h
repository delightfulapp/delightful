//
//  DelightfulLayout.h
//  Delightful
//
//  Created by Nico Prananta on 2/4/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LOADING_VIEW_HEIGHT 50

@interface DelightfulLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) BOOL showLoadingView;

@property (nonatomic, strong, readonly) NSIndexPath *lastIndexPath;

@property (nonatomic, assign) NSInteger numberOfColumns;

- (void)updateLastIndexPath;

@end
