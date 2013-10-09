//
//  PhotoBoxRequestOperation.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/4/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "OVCRequestOperation.h"

@interface PhotoBoxRequestOperation : OVCRequestOperation

@property (strong, nonatomic, readonly) id responseObject;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
