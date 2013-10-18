//
//  DownloadCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NPRImageDownloaderTableViewDataSource.h"

@interface DownloadCell : UITableViewCell <NPRImageDownloaderProgressIndicator>

@property (nonatomic, strong) UIImageView *downloadThumbnailImageView;
@property (nonatomic, strong) UILabel *downloadNameLabel;
@property (nonatomic, strong) UIProgressView *downloadProgressView;

@end
