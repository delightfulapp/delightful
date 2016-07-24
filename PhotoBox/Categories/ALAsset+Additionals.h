//
//  ALAsset+Additionals.h
//  Delightful
//
//  Created by Nico Prananta on 6/10/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Additionals)

- (NSString *)latitudeString;

- (NSString *)longitudeString;

- (NSData *)defaultRepresentationData;

@end
