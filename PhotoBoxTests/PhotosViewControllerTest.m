//
//  PhotosViewControllerTest.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/1/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PhotosViewController.h"

@interface PhotosViewControllerTest : XCTestCase

@end

@implementation PhotosViewControllerTest

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

- (void)testConformToCustomAnimationTransitionFromViewControllerDelegate
{
    PhotosViewController *photos = [[PhotosViewController alloc] init];
    XCTAssert([photos conformsToProtocol:@protocol(CustomAnimationTransitionFromViewControllerDelegate)], @"PhotosViewController has to conform to protocol CustomAnimationTransitionFromViewControllerDelegate");
    XCTAssert([photos respondsToSelector:@selector(imageToAnimate)], @"PhotosViewController need to implement imageToAnimate");
    XCTAssert([photos respondsToSelector:@selector(startRectInContainerView:)], @"PhotosViewController need to implement startRectInContainerView:");
}

@end
