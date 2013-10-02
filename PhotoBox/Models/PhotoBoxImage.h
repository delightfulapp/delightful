//
//  Image.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"

@interface PhotoBoxImage : PhotoBoxModel

@property (nonatomic, copy, readonly) NSString *urlString;
@property (nonatomic, copy, readonly) NSNumber *width;
@property (nonatomic, copy, readonly) NSNumber *height;

- (id)initWithArray:(NSArray *)array;
- (NSArray *)toArray;

@end
