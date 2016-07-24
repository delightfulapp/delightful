//
//  PHAsset+Additionals.h
//  Delightful
//
//  Created by  on 12/24/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Photos/Photos.h>
#import "Bolts.h"

@interface PHAsset (Additionals)

- (BFTask *)fullResolutionImage;

@end
