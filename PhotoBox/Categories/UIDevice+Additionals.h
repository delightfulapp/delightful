//
//  UIDevice+Additionals.h
//  Photos+
//
//  Created by  on 8/12/14.
//  Copyright (c) 2014 Delightful. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIDeviceScreenType) {
    UIDeviceScreenType35Inch,
    UIDeviceScreenType4Inch,
    UIDeviceScreenType47Inch,
    UIDeviceScreenType55Inch,
    UIDeviceScreenTypeiPad
};

@interface UIDevice (Additionals)

+ (CGSize)dimensionOfDeviceScreen:(UIDeviceScreenType)deviceType;
+ (CGSize)dimensionOfDeviceScreen:(UIDeviceScreenType)deviceType retina:(BOOL)retina;
+ (NSArray *)deviceDimensions;

@end
