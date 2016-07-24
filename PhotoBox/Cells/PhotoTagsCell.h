//
//  PhotoTagsCell.h
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoTagsCell;

@protocol PhotoTagsCellDelegate <NSObject>

@optional
- (void)cell:(PhotoTagsCell *)cell didTapButton:(UIButton *)button;

@end

@interface PhotoTagsCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) NSDictionary *tagsDictionary;
@property (nonatomic, assign) CGSize imageViewSize;
@property (nonatomic, strong) NSString *localAssetIdentifier;
@property (nonatomic, weak) id<PhotoTagsCellDelegate>delegate;

@end
