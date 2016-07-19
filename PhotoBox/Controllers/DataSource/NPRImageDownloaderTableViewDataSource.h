//
//  NPRImageDownloaderTableViewDataSource.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NPRImageDownloader.h"

@protocol NPRImageDownloaderProgressIndicator <NSObject>

- (void)downloadProgressDidChange:(float)downloadProgress;

@end


@interface NPRImageDownloaderTableViewDataSource : NSObject <UITableViewDataSource, NPRImageDownloaderDelegate>

@property (nonatomic, copy) void(^cellConfigureBlock)(id cell, NPRImageDownloaderOperation *operation);
@property (nonatomic, copy) NSString *cellIdentifier;

- (id)initWithTableView:(UITableView *)tableView;

@end
