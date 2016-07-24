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
    NSError *error;
    NSArray *array = @[
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"12", @"dateTakenMonth":@"1", @"dateTakenYear":@"2013", @"id": @"aa"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"9", @"dateTakenMonth":@"10", @"dateTakenYear":@"2013", @"id": @"ab"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"9", @"dateTakenMonth":@"10", @"dateTakenYear":@"2013", @"id": @"ac"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"12", @"dateTakenMonth":@"5", @"dateTakenYear":@"2012", @"id": @"ad"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"12", @"dateTakenMonth":@"4", @"dateTakenYear":@"2012", @"id": @"ae"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"5", @"dateTakenMonth":@"4", @"dateTakenYear":@"2012", @"id": @"af"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"7", @"dateTakenMonth":@"1", @"dateTakenYear":@"2013", @"id": @"ag"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"15", @"dateTakenMonth":@"9", @"dateTakenYear":@"2013", @"id": @"ah"} error:&error],
                       [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:@{@"filenameOriginal":@"image", @"dateTakenDay": @"30", @"dateTakenMonth":@"8", @"dateTakenYear":@"2013", @"id": @"ai"} error:&error]
                       ];
    
    NSArray *grouped = [array groupedArrayBy:@"dateMonthYearTakenString"];
    
    XCTAssert(grouped.count==6, @"Wrong number of group. Actual = %d", (int)grouped.count);
    NSDictionary *group1 = [grouped objectAtIndex:0];
    XCTAssert([[group1 objectForKey:@"dateMonthYearTakenString"] isEqualToString:@"2013-10"], @"Wrong first group date. Expected 2013-10. Actual %@", [group1 objectForKey:@"dateMonthYearTakenString"] );
    NSArray *memberOfGroup1 = [group1 objectForKey:@"members"];
    XCTAssert(memberOfGroup1.count == 2, @"Wrong number of members in group. Expected 2. Actual %lu", (unsigned long)memberOfGroup1.count);
}

@end
