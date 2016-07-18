//
//  SharingTokenTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/18/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "APIClient.h"
#import "ConnectionManager.h"

@interface SharingTokenTests : XCTestCase

@end

@implementation SharingTokenTests

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

/*
- (void)testFetchSharingTokenSuccess
{
    NSString *photoId = @"111";
    NSString *mockToken = @"photoToken";
    NSString *path = [NSString stringWithFormat: @"/token/photo/%@/create.json", photoId];
    
    APIClient *client = [APIClient sharedClient];
    id mockClient = [OCMockObject partialMockForObject:client];
    [[[mockClient expect] andDo:^(NSInvocation *invocation) {
        void(^successBlock)(NSOperation *,id) = nil;
        [invocation getArgument:&successBlock atIndex:4];
        successBlock(nil, @{@"result": @{@"id": mockToken}});
    } ] postPath:path parameters:nil success:[OCMArg any] failure:[OCMArg any]];
    
    [mockClient fetchSharingTokenForPhotoWithId:photoId completionBlock:^(NSString *token) {
        XCTAssert([token isEqualToString:mockToken], @"Expected %@. Actual %@.", mockToken, token);
    }];
    
    [mockClient verify];
}

- (void)testFetchSharingTokenFailure
{
    NSString *photoId = @"111";
    NSString *mockToken = @"photoToken";
    NSString *path = [NSString stringWithFormat: @"/token/photo/%@/create.json", photoId];
    
    APIClient *client = [APIClient sharedClient];
    id mockClient = [OCMockObject partialMockForObject:client];
    [[[mockClient expect] andDo:^(NSInvocation *invocation) {
        void(^successBlock)(NSOperation *,id) = nil;
        [invocation getArgument:&successBlock atIndex:4];
        successBlock(nil, @{@"result": @""});
    } ] postPath:path parameters:nil success:[OCMArg any] failure:[OCMArg any]];
    
    [mockClient fetchSharingTokenForPhotoWithId:photoId completionBlock:^(NSString *token) {
        XCTAssertFalse([token isEqualToString:mockToken], @"Expected %@. Actual %@.", mockToken, token);
    }];
    
    [mockClient verify];
}
 */

@end
