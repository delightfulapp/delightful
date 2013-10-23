//
//  PanelFactory.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PanelFactory : NSObject

+ (NSArray *)panelsForVersion:(NSString *)version;
+ (UIImage *)imageBackgroundForVersion:(NSString *)version;

@end
