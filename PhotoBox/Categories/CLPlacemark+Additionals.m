//
//  CLPlacemark+Additionals.m
//  Delightful
//
//  Created by Nico Prananta on 7/19/16.
//  Copyright © 2016 DelightfulDev. All rights reserved.
//

#import "CLPlacemark+Additionals.h"

@implementation CLPlacemark (Additionals)

- (NSString *)locationString {
    NSString *placemarkName = self.name;
    NSString *placemarkLocality = self.locality;
    if (placemarkLocality) {
        NSArray *localityComponents = [placemarkLocality componentsSeparatedByString:@","];
        placemarkLocality = [localityComponents lastObject];
    }
    NSString *placemarkCountry = self.country;
    NSString *placeName = @"";
    if (placemarkName) {
        NSArray *nameComponents = [placemarkName componentsSeparatedByString:@","];
        if (nameComponents.count > 1) {
            NSString *placemarkNameToUse = @"";
            for (NSString *component in nameComponents) {
                NSString *com = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (com.length > placemarkNameToUse.length) {
                    placemarkNameToUse = com;
                }
            }
            placemarkName = placemarkNameToUse;
        }
        
        if (placemarkLocality && placemarkCountry) {
            placeName = [NSString stringWithFormat:@"%@, %@, %@", placemarkName, placemarkLocality, placemarkCountry];
        } else if (placemarkLocality) {
            placeName = [NSString stringWithFormat:@"%@, %@", placemarkName, placemarkLocality];
        } else if (placemarkCountry) {
            placeName = [NSString stringWithFormat:@"%@, %@", placemarkName, placemarkCountry];
        }
    } else {
        if (placemarkLocality && placemarkCountry) {
            placeName = [NSString stringWithFormat:@"%@ %@", placemarkLocality, placemarkCountry];
        } else if (placemarkCountry) {
            placeName = placemarkCountry;
        }
    }
    
    return placeName;
}

@end
