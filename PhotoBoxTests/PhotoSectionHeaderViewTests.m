//
//  PhotoSectionHeaderViewTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PhotosSectionHeaderView.h"

@interface PhotosSectionHeaderView ()

- (NSAttributedString *)attributedStringWithTitle:(NSString *)title location:(NSString *)location;

@end

@interface PhotoSectionHeaderViewTests : XCTestCase

@end

@implementation PhotoSectionHeaderViewTests

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

- (void)testAttributedStringWithTitleAndLocation
{
    PhotosSectionHeaderView *section = [[PhotosSectionHeaderView alloc] init];
    NSAttributedString *string = [section attributedStringWithTitle:nil location:nil];
    
    XCTAssert(string==nil, @"Attributed should be nil");
    
    string = [section attributedStringWithTitle:@"Some title" location:nil];
    XCTAssert([string.string isEqualToString:@"Some title"], @"Actual: %@", string.string);
    
    string = [section attributedStringWithTitle:@"title" location:@"location"];
    XCTAssert([string.string isEqualToString:@"title\nlocation"], @"Actual: %@", string.string);
}

@end
