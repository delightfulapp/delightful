//
//  PhotoTagsCell.h
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTagsCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, assign) CGSize imageViewSize;

@end
