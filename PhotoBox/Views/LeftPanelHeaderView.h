//
//  LeftPanelHeaderView.h
//  Delightful
//
//  Created by Nico Prananta on 5/11/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftPanelHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadedButton;
@property (weak, nonatomic) IBOutlet UIImageView *galleryArrow;
@property (weak, nonatomic) IBOutlet UIImageView *downloadedArrow;

@end
