//
//  APIClientTest.m
//  Delightful
//
//  Created by Nico Prananta on 7/17/16.
//  Copyright © 2016 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "APIClient.h"
#import "XCTestCase+Additionals.h"

@interface APIClient ()
- (BOOL)isLoggedIn;
- (NSDictionary *)photoSizesDictionary;
- (NSString *)sortByQueryDictionary:(NSString *)sortBy;
- (NSString *)albumsQueryDictionary:(NSString *)album;
- (NSString *)tagsQueryDictionary:(NSString *)tag;
- (NSURL *)baseURL;
@end

@interface APIClientTest : XCTestCase
@end

@implementation APIClientTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetPhotosSuccessBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *photos = [self objectFromJSONFile:@"photos"];
        NSError *error = nil;
        NSData *stubData = [NSJSONSerialization dataWithJSONObject:photos options:0 error:&error];
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:nil];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    id expectation = [self expectationWithDescription:@"getPhotos return objects"];
    NSURLSessionDataTask * dataTask = [apiClientMock getPhotosForPage:0 sort:nil pageSize:10 success:^(id object) {
        XCTAssertNotNil(object);
        NSArray *photos = (NSArray *)object;
        XCTAssertEqual((int)[photos count], 2);
        [expectation fulfill];
    } failure:^(NSError *error) {
        
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testGetPhotosErrorBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    
    id expectation = [self expectationWithDescription:@"getPhotos call error block"];
    NSURLSessionDataTask * dataTask = [apiClientMock getPhotosForPage:0 sort:nil pageSize:10 success:^(id object) {
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testGetAlbumsSuccessBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *photos = [self objectFromJSONFile:@"albums"];
        NSError *error = nil;
        NSData *stubData = [NSJSONSerialization dataWithJSONObject:photos options:0 error:&error];
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:nil];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    
    id expectation = [self expectationWithDescription:@"getAlbums return objects"];
    NSURLSessionDataTask * dataTask = [apiClientMock getAlbumsForPage:0 pageSize:10 success:^(id object) {
        XCTAssertNotNil(object);
        NSArray *photos = (NSArray *)object;
        XCTAssertEqual((int)[photos count], 3);
        [expectation fulfill];
    } failure:^(NSError *error) {
        
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testGetAlbumsErrorBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    
    id expectation = [self expectationWithDescription:@"getAlbums call error block"];
    NSURLSessionDataTask * dataTask = [apiClientMock getAlbumsForPage:0 pageSize:10 success:^(id object) {
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testGetTagsSuccessBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSDictionary *tags = [self objectFromJSONFile:@"tags"];
        NSError *error = nil;
        NSData *stubData = [NSJSONSerialization dataWithJSONObject:tags options:0 error:&error];
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:nil];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    
    id expectation = [self expectationWithDescription:@"getTags return objects"];
    NSURLSessionDataTask * dataTask = [apiClientMock getTagsForPage:0 pageSize:10 success:^(id object) {
        XCTAssertNotNil(object);
        NSArray *photos = (NSArray *)object;
        XCTAssertEqual((int)[photos count], 3);
        [expectation fulfill];
    } failure:^(NSError *error) {
        
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testGetTagsErrorBlock {
    id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]];
    }];
    
    APIClient *apiClient = [[APIClient alloc] init];
    id apiClientMock = OCMPartialMock(apiClient);
    OCMStub([apiClientMock isLoggedIn]).andReturn(YES);
    OCMStub([apiClientMock baseURL]).andReturn([NSURL URLWithString:@"http://trovebox.dev"]);
    
    
    id expectation = [self expectationWithDescription:@"getTags call error block"];
    NSURLSessionDataTask * dataTask = [apiClientMock getTagsForPage:0 pageSize:10 success:^(id object) {
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    
    XCTAssertNotNil(dataTask);
    XCTAssertNotNil(dataTask.originalRequest);
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
        
    }];
    [OHHTTPStubs removeStub:stub];
}

- (void)testQueryStrings {
    APIClient *apiClient = [[APIClient alloc] init];
    XCTAssertNotNil([apiClient photoSizesDictionary]);
    
    XCTAssertNotNil([apiClient sortByQueryDictionary:@"test"]);
    
    XCTAssertNotNil([apiClient albumsQueryDictionary:@"album"]);
    
    XCTAssertNotNil([apiClient tagsQueryDictionary:@"tags"]);
}

@end
