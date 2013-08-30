//
//  NSObject+setValuesForKeysWithJSONDictionary.h
//
//  Created by Tom Harrington on 12/29/11.
//  Tweaked by Mark Dalrymple
//
//  Copyright (c) 2011 Atomic Bird, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Safe version of -setValuesForKeysWithDictionary that doesn't throw
// if there are unexpected keys in the dictionary (which can be bad if you
// don't control the web site).  
//
// It walks the properties of the class (and the corresponding ivars) and sees
// if they're in the pased-in "json" dictionary.  If so, the values are set onto
// |self| via KVC.  Any values in the dictionary that don't have corresponding
// properties/ivars are not even considered.


@interface NSObject (XXSetValuesForKeysWithJSONDictionary)

- (void) xx_setValuesForKeysWithJSONDictionary: (NSDictionary *) keyedValues
                                 dateFormatter: (NSDateFormatter *) dateFormatter;

- (void) xx_setValuesForKeysWithJSONDictionary: (NSDictionary *) keyedValues;

@end 
