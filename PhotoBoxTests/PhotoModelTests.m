//
//  PhotoModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Photo.h"
#import "Album.h"

#import "XCTestCase+Additionals.h"

@interface PhotoModelTests : XCTestCase

@end

@implementation PhotoModelTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPhotoObjectJSONSerialization
{
    NSError *error;
    NSDictionary *photoDictionary = [self objectFromJSONFile:@"photo"];
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:photoDictionary error:&error];
    XCTAssertTrue(photo.thumbnailImage, @"Expected thumbnail image");
    XCTAssertTrue([photo.thumbnailImage.urlString isEqualToString:[photoDictionary objectForKey:@"path200x200xCR"]], @"Expected thumbnail image url %@. Actual %@", [photoDictionary objectForKey:@"path200x200xCR"], photo.thumbnailImage.urlString);
    XCTAssertTrue([photo.normalImage.urlString isEqualToString:[photoDictionary objectForKey:@"path640x640"]], @"Expected normal image url %@. Actual %@", [photoDictionary objectForKey:@"path640x640"], photo.normalImage.urlString);
}

- (void)testPhotoObjectManagedObjectSerialization {
    NSError *error;
    NSDictionary *photoDictionary = [self objectFromJSONFile:@"photo"];
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:photoDictionary error:&error];
    NSManagedObject *photoManagedObject = [MTLManagedObjectAdapter managedObjectFromModel:photo insertingIntoContext:[NSManagedObjectContext mainContext] error:&error];
    XCTAssert(photoManagedObject != nil, @"Photo managed object should not be nil");
    XCTAssert([[photoManagedObject valueForKey:@"photoId"] isEqualToString:[photoDictionary objectForKey:@"id"]], @"Expected photo id = %@. Actual = %@", photoDictionary[@"id"], [photoManagedObject valueForKey:@"photoId"]);
    XCTAssert(((NSArray *)[photoManagedObject valueForKey:@"albums"]).count == 2, @"Expected 2 albums. Actual = %d", ((NSArray *)[photoManagedObject valueForKey:@"albums"]).count);
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"albumId" ascending:YES];
    XCTAssert([((Album *)[[[((NSSet *)[photoManagedObject valueForKey:@"albums"]) allObjects] sortedArrayUsingDescriptors:@[descriptor]] objectAtIndex:0]).albumId isEqualToString:@"1"], @"Expected first album id = 1. Actual = %@", ((Album *)[[((NSSet *)[photoManagedObject valueForKey:@"albums"]) allObjects] objectAtIndex:0]).albumId);
}

@end
