//
//  NSString+AdditionalsTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+Additionals.h"

@interface NSString_AdditionalsTests : XCTestCase

@end

@implementation NSString_AdditionalsTests

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

- (void)testIsURL
{
    NSString *url = @"http://somebody.trovebox.com";
    XCTAssertTrue([url isValidURL], @"URL should be valid");
    url = @"somebody.trovebox.com";
    XCTAssertTrue([url isValidURL], @"URL should be valid");
}

@end
