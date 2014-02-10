//
//  FetchedIn.m
//  Delightful
//
//  Created by Nico Prananta on 2/8/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FetchedIn.h"

#import "Photo.h"

@implementation FetchedIn

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return @{ NSStringFromSelector(@selector(photo)):Photo.class};
}

@end
