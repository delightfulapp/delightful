//
//  Tag.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosCollection.h"

@interface Tag : PhotosCollection

@property (nonatomic, copy, readonly) NSString *actor;
@property (nonatomic, copy, readonly) NSNumber *count;
@property (nonatomic, copy, readonly) NSString *extra;
@property (nonatomic, copy, readonly) NSString *tagId;
@property (nonatomic, copy, readonly) NSString *owner;


@end
