//
//  FetchedIn.h
//  Delightful
//
//  Created by Nico Prananta on 2/8/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotoBoxModel.h"

@class Photo;

@interface FetchedIn : PhotoBoxModel

@property (nonatomic, copy, readonly) NSString *fetchedIn;

@property (nonatomic, copy, readonly) Photo *photo;

@end
