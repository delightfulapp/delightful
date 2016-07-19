//
//  PhotosSectionHeaderView.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLPlacemark;

@interface PhotosSectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL hideLocation;

@property (nonatomic, strong) NSString *titleLabelText;

- (void)setLocation:(CLPlacemark *)placemark;

- (void)setLocationString:(NSString *)location;

- (void)setup;

@end
