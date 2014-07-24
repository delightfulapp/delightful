//
//  UploadAssetCell.h
//  Delightful
//
//  Created by Nico Prananta on 6/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotoBoxCell.h"

@interface UploadAssetCell : PhotoBoxCell

- (void)setUploadProgress:(float)progress;
- (void)removeUploadProgress;

@property (nonatomic, assign, readonly) float uploadProg;

@end
