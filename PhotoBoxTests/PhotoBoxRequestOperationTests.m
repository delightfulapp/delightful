//
//  PhotoBoxRequestOperationTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/4/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XCTestCase+Additionals.h"
#import <NSManagedObjectContext+OGCoreDataStack.h>

#import "PhotoBoxRequestOperation.h"
#import "Photo.h"
#import "NSArray+Additionals.h"
#import <OCMock.h>

@interface PhotoBoxRequestOperationTests : XCTestCase {
    id mockRequest;
    NSValueTransformer *transformer;
    NSDictionary *photoJSON;
    NSDictionary *responseJSON;
    NSManagedObjectContext *workContext;
    NSManagedObjectContext *mainContext;
}

@end

@implementation PhotoBoxRequestOperationTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    if ([NSPersistentStoreCoordinator persistentStoreCoordinator]) {
        [NSPersistentStoreCoordinator clearPersistentStore];
    }
    
    // mock objects
    mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    transformer = [PhotoBoxRequestOperation valueTransformerWithResultClass:[Photo class] resultKeyPath:@"result"];
    
    // get dummy data
    photoJSON = [self objectFromJSONFile:@"photo"];
    responseJSON = @{@"result": @[photoJSON]};
    
    // managed object context
    mainContext = [NSManagedObjectContext mainContext];
    workContext = [NSManagedObjectContext workContext];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
    
    mockRequest = nil;
    transformer = nil;
}

- (PhotoBoxRequestOperation *)operation {
    return [[PhotoBoxRequestOperation alloc] initWithRequest:mockRequest resultClass:[Photo class] resultKeyPath:@"result"];
}

- (void)testResponseObjectWithoutManagedObjectSerialization
{
    [self performResponseObjectTestWithManagedObjectContext:nil];
}

- (void)testResponseObjectWithManagedObjectSerialization {
    [self performResponseObjectTestWithManagedObjectContext:workContext];
}

- (void)performResponseObjectTestWithManagedObjectContext:(NSManagedObjectContext *)context {
    // init the operation to test
    PhotoBoxRequestOperation *operation = self.operation;
    
    // assign transformer
    [operation setValueTransformer:transformer];
    
    // assign context
    if (context) {
        [operation setUseCoreData:YES];
    } else {
        [operation setUseCoreData:NO];
    }
    
    // partially mock the operation
    id mockOperation = [OCMockObject partialMockForObject:operation];
    
    // mock property responseJSON
    [[[mockOperation expect] andReturn:responseJSON] responseJSON];
    
    // test the responseObject!
    NSArray *responseObject = [mockOperation responseObject];
    
    // assert
    XCTAssert([responseObject isKindOfClass:[NSArray class]], @"Expected array of photos. Actual %@", NSStringFromClass([responseObject class]));
    XCTAssert(responseObject.count==1, @"There should be 1 photo. Actual %d", responseObject.count);
    Photo *photo = responseObject[0];
    XCTAssert([photo.photoId isEqualToString:@"bd"], @"Expected photoId = bd. Actual = %@", photo.photoId);
    XCTAssert(photo.albums.count == ((NSArray *)photoJSON[@"albums"]).count, @"Expected %d. Actual %d", ((NSArray *)photoJSON[@"albums"]).count, photo.albums.count);
    
    if (context) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"PBXPhoto" inManagedObjectContext:mainContext];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"photoId == %@", photo.photoId];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchLimit = 1;
        
        NSError *fetchRequestError;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchRequestError];
        
        XCTAssert(results!=nil, @"Fetch results should not be nil.");
        XCTAssert(results.count==1, @"Expected 1 result from fetch. Actual = %d", results.count);
        NSManagedObject *photoObject = results[0];
        XCTAssert(photoObject!=nil, @"Photo managed object should not be nil");
        XCTAssert([[photoObject valueForKey:@"photoId"] isEqualToString:@"bd"], @"Expected photoId from managed object = bd. Actual = %@", [photoObject valueForKey:@"photoId"]);
        NSString *albumsString = [photoObject valueForKey:@"albums"];
        NSString *expectedAlbumsString = [((NSArray *)photoJSON[@"albums"]) photoBoxArrayString];
        XCTAssert([albumsString isEqualToString:expectedAlbumsString], @"Expected %@. Actual %@", expectedAlbumsString, albumsString);
    }
    
    // verify
    [mockOperation verify];
}

@end
