//
//  NSObject+setValuesForKeysWithJSONDictionary.m
//
//  Created by Tom Harrington on 12/29/11.
//  Tweaked by Mark Dalrymple
//
//  Copyright (c) 2011 Atomic Bird, LLC. All rights reserved.
//

#import "NSObject+setValuesForKeysWithJSONDictionary.h"

#import <objc/runtime.h>

@implementation NSObject (XXSetValuesForKeysWithJSONDictionary)

// Alternative implementation - class_getProperty, driven by the keyedValues

- (void) xx_setValuesForKeysWithJSONDictionary: (NSDictionary *) keyedValues
                                 dateFormatter: (NSDateFormatter *) dateFormatter {

    // Walk the current class, as well as superclasses.  The property or ivar
    // to set might be up in the inheritance chain.
    for (Class clas = [self class]; clas; clas = class_getSuperclass(clas)) {

        // Walk the properties seeing if any of the properties appear in
        // the dictionary of JSON values.
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(clas, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];

            // See if the property name is being used in the JSON dictionary.
            // If so, get the current value.
            NSString *keyName = @( property_getName(property) );
            id value = [keyedValues objectForKey:keyName];
        
            // If not, see if it's the backing ivar name being supplied
            // in the JSON dictionary.

            if (value == nil) {
                // Pull the ivar name out of the property.
                char *ivarPropertyName = property_copyAttributeValue(property, "V");

                // Make sure we're not dealing with a @dynamic property
                if (ivarPropertyName != NULL) {
                    // See if that lives in the incoming dictionary.
                    // We don't need to change the value of keyName to match the
                    // ivar because it already matches the property, and
                    // setValue:forKey: of that property name will Just Work.
                    NSString *ivarName = @( ivarPropertyName );
                    value = [keyedValues objectForKey: ivarName];
                }
                free (ivarPropertyName);
            }

            if (value == nil) {
                // This property doesn't have anything in the incoming dictionary.
                continue;
            }

            // otherwise, process the value
            char *typeEncoding = property_copyAttributeValue(property, "T");
            
            // No type available, so we're done.
            if (typeEncoding == NULL) {
                continue;
            }

            // We got here because this property has a corresponding new chunk of
            // data in the json dictionary.  Time to put it into |self|.
            // We might have to morph the incoming value (such as a provided number, 
            // but it needs to converted to a string).

            switch (typeEncoding[0]) {
            case '@': {
                // Object
                Class propertyClass = nil;
                size_t typeEncodingLength = strlen(typeEncoding);
                if (typeEncodingLength >= 3) {
                    char *className = strndup (typeEncoding + 2,
                                               typeEncodingLength - 3);
                    propertyClass = NSClassFromString (@(className));
                    free (className);
                }

                // Check for type mismatch and attempt to compensate.

                if ([propertyClass isSubclassOfClass:[NSString class]] 
                    && [value isKindOfClass:[NSNumber class]]) {
                    // number converted into a string.
                    value = [value stringValue];

                } else if ([propertyClass isSubclassOfClass:[NSNumber class]] 
                           && [value isKindOfClass:[NSString class]]) {
                    // String converted into a number.  We can't tell what its
                    // intention ls (float, integer, etc), so let the number
                    // formatter make a best guess for us.
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    value = [numberFormatter numberFromString:value];

                } else if (dateFormatter
                           && [propertyClass isSubclassOfClass:[NSDate class]] 
                           && [value isKindOfClass:[NSString class]]) {
                    // If the caller provided a date formatter, try converting
                    // the date into a string.
                    value = [dateFormatter dateFromString:value];
                }
                
                break;
            }
            
            case 'i': // int
            case 's': // short
            case 'l': // long
            case 'q': // long long
            case 'I': // unsigned int
            case 'S': // unsigned short
            case 'L': // unsigned long
            case 'Q': // unsigned long long
            case 'f': // float
            case 'd': // double
            case 'B': // BOOL
                if ([value isKindOfClass:[NSString class]]) {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    value = [numberFormatter numberFromString:value];
                }
                break;
            
            case 'c': // char
            case 'C': // unsigned char
                if ([value isKindOfClass:[NSString class]]) {
                    char firstCharacter = (char)[value characterAtIndex:0];
                    value = [NSNumber numberWithChar:firstCharacter];
                }
                break;
            
            default:
                break;
            }

            if (value) {
                [self setValue: value  forKey: keyName];
            }

            free(typeEncoding);
        }
        free (properties);
    }

} // setValues with dateFormatter


- (void) xx_setValuesForKeysWithJSONDictionary: (NSDictionary *) keyedValues {
    [self xx_setValuesForKeysWithJSONDictionary:keyedValues dateFormatter:nil];
} // setValues

@end
