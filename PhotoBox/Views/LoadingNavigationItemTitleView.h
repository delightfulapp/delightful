//
//  LoadingNavigationItemTitleView.h
//  Delightful
//
//  Created by  on 12/25/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingNavigationItemTitleView : UIView

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *indicatorView;

@end
