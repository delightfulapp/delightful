//
//  NPRImageView+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRImageView+Additionals.h"

@implementation NPRImageView (Additionals)

- (BOOL)hasDownloadedOriginalImageAtURL:(NSString *)url {
    return ([self.sharedCache imageExistsOnDiskWithKey:url]);
}

@end
