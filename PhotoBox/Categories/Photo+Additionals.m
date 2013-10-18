//
//  Photo+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/19/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Photo+Additionals.h"

@implementation Photo (Additionals)

- (NSURL *)sharedURLWithToken:(NSString *)token {
    return [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"token-%@", token]];
}

@end
