//
//  UIDevice+Additionals.m
//  Photos+
//
//  Created by  on 8/12/14.
//  Copyright (c) 2014 Delightful. All rights reserved.
//

#import "UIDevice+Additionals.h"

@implementation UIDevice (Additionals)

+ (CGSize)dimensionOfDeviceScreen:(UIDeviceScreenType)deviceType {
    return [UIDevice dimensionOfDeviceScreen:deviceType retina:NO];
}

+ (CGSize)dimensionOfDeviceScreen:(UIDeviceScreenType)deviceType retina:(BOOL)retina {
    int scale = (retina)?2:1;
    switch (deviceType) {
        case UIDeviceScreenType35Inch:
            return CGSizeMake(320*scale, 480*scale);
            break;
        case UIDeviceScreenType4Inch:
            return CGSizeMake(320*scale, 568*scale);
            break;
        case UIDeviceScreenTypeiPad:
            return CGSizeMake(768*scale, 1024*scale);
            break;
        default:
            break;
    }
    return CGSizeZero;
}

+ (NSArray *)deviceDimensions {
    CGSize threeHalfInchSize = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenType35Inch];
    CGSize threeHalfInchSizeRetina = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenType35Inch retina:YES];
    CGSize fourInchSize = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenType4Inch];
    CGSize fourInchSizeRetina = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenType4Inch retina:YES];
    CGSize iPadSize = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenTypeiPad];
    CGSize iPadSizeRetina = [UIDevice dimensionOfDeviceScreen:UIDeviceScreenTypeiPad retina:YES];
    
    return @[[NSValue valueWithCGSize:threeHalfInchSize],
             [NSValue valueWithCGSize:threeHalfInchSizeRetina],
             [NSValue valueWithCGSize:fourInchSize],
             [NSValue valueWithCGSize:fourInchSizeRetina],
             [NSValue valueWithCGSize:iPadSize],
             [NSValue valueWithCGSize:iPadSizeRetina]];
}

@end
