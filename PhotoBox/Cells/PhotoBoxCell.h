//
//  PhotoBoxCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImageView+WebCache.h"

@interface PhotoBoxCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;

@property (nonatomic, strong) id item;

- (void)setup;

@end
