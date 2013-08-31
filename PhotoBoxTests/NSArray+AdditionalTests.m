//
//  NSArray+AdditionalTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+Additionals.h"
#import "Photo.h"

@interface NSArray_AdditionalTests : XCTestCase

@end

@implementation NSArray_AdditionalTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testGroupPhotos
{
    NSArray *array = @[
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(12), @"dateTakenMonth":@(1), @"dateTakenYear":@(2013)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(9), @"dateTakenMonth":@(10), @"dateTakenYear":@(2013)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(9), @"dateTakenMonth":@(10), @"dateTakenYear":@(2013)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(12), @"dateTakenMonth":@(5), @"dateTakenYear":@(2012)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(12), @"dateTakenMonth":@(4), @"dateTakenYear":@(2012)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(5), @"dateTakenMonth":@(4), @"dateTakenYear":@(2012)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(7), @"dateTakenMonth":@(1), @"dateTakenYear":@(2013)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(15), @"dateTakenMonth":@(9), @"dateTakenYear":@(2013)}],
                       [[Photo alloc] initWithDictionary:@{@"dateTakenDay": @(30), @"dateTakenMonth":@(8), @"dateTakenYear":@(2013)}],
                       ];
    
    NSArray *grouped = [array groupedArrayBy:@"dateMonthYearTakenString"];
    XCTAssert(grouped.count==6, @"Wrong number of group");
    NSDictionary *group1 = [grouped objectAtIndex:0];
    XCTAssert([[group1 objectForKey:@"dateMonthYearTakenString"] isEqualToString:@"2013-10"], @"Wrong first group date. Expected 2013-10. Actual %@", [group1 objectForKey:@"dateMonthYearTakenString"] );
    NSArray *memberOfGroup1 = [group1 objectForKey:@"members"];
    XCTAssert(memberOfGroup1.count == 2, @"Wrong number of members in group. Expected 2. Actual %d", memberOfGroup1.count);
}

@end
