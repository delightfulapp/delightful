//
//  AlbumsPickerTableViewController.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "AlbumsViewController.h"

@class AlbumsPickerViewController;

@class Album;

@protocol AlbumsPickerViewControllerDelegate <NSObject>

@optional
- (void)albumsPickerViewController:(AlbumsPickerViewController *)albumsPicker didSelectAlbum:(Album *)album;

@end

@interface AlbumsPickerViewController : AlbumsViewController

@property (nonatomic, weak) id<AlbumsPickerViewControllerDelegate>delegate;

@property (nonatomic, strong) Album *selectedAlbum;

@end
