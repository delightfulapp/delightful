//
//  PhotoModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Photo.h"

@interface PhotoModelTests : XCTestCase

@end

@implementation PhotoModelTests

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

- (void)testSetNormalImage
{
    Photo *photo = [[Photo alloc] initWithDictionary:@{@"id": @"1",
                                                       @"photo640x640":@[@"http://image640x640.png", @(640), @(480)],
                                                       @"photo200x200xCR":@[@"http://image200x200xCR.png", @(200), @(200)]
                                                       }];
    XCTAssertTrue(photo.thumbnailImage, @"Expected thumbnail image");
    XCTAssertTrue([photo.thumbnailImage.urlString isEqualToString:@"http://image200x200xCR.png"], @"Expected thumbnail image url http://image200x200xCR.png. Actual %@", photo.thumbnailImage.urlString);
    XCTAssertTrue([photo.normalImage.urlString isEqualToString:@"http://image640x640.png"], @"Expected normal image url http://image640x640.png. Actual %@", photo.normalImage.urlString);
}

@end
