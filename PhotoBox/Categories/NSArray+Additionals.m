//
//  NSArray+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NSArray+Additionals.h"

@implementation NSArray (Additionals)

- (NSArray *)groupedArrayBy:(NSString *)property {
    NSArray *groups = [self valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", property]];
    groups = [groups sortedArrayUsingSelector:@selector(localizedCompare:)];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:groups.count];
    for (NSString *group in groups.reverseObjectEnumerator) {
        NSMutableDictionary *groupDictionary = [NSMutableDictionary dictionary];
        [groupDictionary setObject:group forKey:property];
        NSArray *groupMembers = [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", property, group]];
        [groupDictionary setObject:groupMembers forKey:@"members"];
        [array addObject:groupDictionary];
    }
    
    return array;
}

- (NSString *)photoBoxArrayString {
    NSString *arrayString = [self componentsJoinedByString:ARRAY_SEPARATOR];
    return [NSString stringWithFormat:@"%@%@%@", ARRAY_SEPARATOR, arrayString, ARRAY_SEPARATOR];
}

@end
