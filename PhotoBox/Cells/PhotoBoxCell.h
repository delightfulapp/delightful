//
//  PhotoBoxCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <NPRImageView.h>

@interface PhotoBoxCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet NPRImageView *cellImageView;

@property (nonatomic, strong) id item;

@end
