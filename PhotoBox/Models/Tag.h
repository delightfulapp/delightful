//
//  Tag.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"

@interface Tag : PhotoBoxModel

@property (nonatomic, strong) NSString *actor;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) NSString *extra;
@property (nonatomic, strong) NSString *tagId;
@property (nonatomic, strong) NSString *owner;

@end
