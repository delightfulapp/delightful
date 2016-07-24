//
//  LocalViewController.h
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SelectedViewControllerIndex) {
    FavoritesViewControllerSelected,
    DownloadedViewControllerSelected
};

@interface LocalViewController : UITabBarController

- (IBAction)selectedSegmentDidChange:(id)sender;

@end
