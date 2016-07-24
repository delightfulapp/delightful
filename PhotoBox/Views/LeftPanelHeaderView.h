//
//  LeftPanelHeaderView.h
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftPanelHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadedButton;
@property (weak, nonatomic) IBOutlet UIImageView *galleryArrow;
@property (weak, nonatomic) IBOutlet UIImageView *downloadedArrow;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *favoriteToDownloadedSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downloadedToGalleryConstraint;

@end
