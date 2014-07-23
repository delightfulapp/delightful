//
//  AlbumsPickerTableViewController.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumsPickerTableViewController;

@class Album;

@protocol AlbumsPickerTableViewControllerPickerDelegate <NSObject>

@optional
- (void)albumsPickerViewController:(AlbumsPickerTableViewController *)albumsPicker didSelectAlbum:(Album *)album;

@end

@interface AlbumsPickerTableViewController : UITableViewController

@property (nonatomic, weak) id<AlbumsPickerTableViewControllerPickerDelegate>delegate;

@property (nonatomic, strong) Album *selectedAlbum;

@end
