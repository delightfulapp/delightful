//
//  XCTestCase+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "XCTestCase+Additionals.h"

@implementation XCTestCase (Additionals)

- (id)objectFromJSONFile:(NSString *)jsonFile {
    NSError *error;
    NSString * filePath = [[NSBundle bundleForClass:[self class]] pathForResource:jsonFile ofType:@"json"];
    id object = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&error];
    NSAssert(error==nil, @"%@ => %@", jsonFile, error);
    return object;
}

@end
