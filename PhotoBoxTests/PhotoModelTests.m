//
//  PhotoModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Photo.h"

#import "XCTestCase+Additionals.h"

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
    NSError *error;
    NSDictionary *photoDictionary = [self objectFromJSONFile:@"photo"];
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:photoDictionary error:&error];
    XCTAssertTrue(photo.thumbnailImage, @"Expected thumbnail image");
    XCTAssertTrue([photo.thumbnailImage.urlString isEqualToString:[photoDictionary objectForKey:@"path200x200xCR"]], @"Expected thumbnail image url %@. Actual %@", [photoDictionary objectForKey:@"path200x200xCR"], photo.thumbnailImage.urlString);
    XCTAssertTrue([photo.normalImage.urlString isEqualToString:[photoDictionary objectForKey:@"path640x640"]], @"Expected normal image url %@. Actual %@", [photoDictionary objectForKey:@"path640x640"], photo.normalImage.urlString);
}

@end
