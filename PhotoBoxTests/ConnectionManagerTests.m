//
//  APIClient+URLsTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/5/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ConnectionManager.h"
#import <OCMock/OCMock.h>


@interface ConnectionManagerTests : XCTestCase

@end

@implementation ConnectionManagerTests

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

- (void)testOauthURL
{
    NSString *baseURL = @"http://someone.trovebox.com";
    NSURL *initialOauthURL = [ConnectionManager oAuthInitialUrlForServer:baseURL];
    XCTAssertTrue([initialOauthURL.absoluteString isEqualToString:@"http://someone.trovebox.com/v1/oauth/authorize?oauth_callback=delightful://&name=Delightful"], @"Expected initial URL: http://someone.trovebox.com/v1/oauth/authorize?oauth_callback=delightful://&name=Delightful Actual: %@", initialOauthURL.absoluteString);
    NSURL *oauthAccessURL = [ConnectionManager oAuthAccessUrlForServer:baseURL];
    XCTAssertTrue([oauthAccessURL.absoluteString isEqualToString:@"http://someone.trovebox.com/v1/oauth/token/access"], @"Expected access URL: http://someone.trovebox.com/v1/oauth/token/access Actual: %@", oauthAccessURL.absoluteString);
}

@end
