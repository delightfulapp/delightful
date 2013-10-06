//
//  AlbumModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XCTestCase+Additionals.h"

#import "Album.h"
#import "PhotoBoxModel.h"
#import "Photo.h"
#import "Tag.h"

@interface AlbumModelTests : XCTestCase

@end

@implementation AlbumModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    [NSPersistentStoreCoordinator clearPersistentStore];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSerializeAlbum
{
    NSError *error;

    NSDictionary *albumDict = [self objectFromJSONFile:@"album"];
    Album *testAlbum = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:albumDict error:&error];
    
    XCTAssert(testAlbum!=nil, @"Test album should not be nil");
    XCTAssert([testAlbum.albumId isEqualToString:albumDict[@"id"]], @"Expected test album id = %@. Actual = %@",albumDict[@"id"], testAlbum.albumId);
    XCTAssert([testAlbum.count intValue]==[albumDict[@"count"] intValue], @"Expected album count = %d. Actual = %d",[albumDict[@"count"] intValue], [testAlbum.count intValue]);
    XCTAssert([testAlbum.name isEqualToString:[albumDict objectForKey:@"name"]], @"Expected album name = %@. Actual = %@", [albumDict objectForKey:@"name"], testAlbum.name);
    
    // test cover's original image
    XCTAssert(testAlbum.cover!=nil, @"Album cover should not be nil");
    XCTAssert(testAlbum.cover.originalImage!=nil, @"Original image should not be nil");
    XCTAssert([testAlbum.cover.originalImage.urlString isEqualToString:[[albumDict objectForKey:@"cover"] objectForKey:@"pathOriginal"]], @"Expected original image = %@. Actual = %@", [[albumDict objectForKey:@"cover"] objectForKey:@"pathOriginal"], testAlbum.cover.originalImage.urlString);
    
    // test cover's thumbnail image
    XCTAssert(testAlbum.cover.thumbnailImage!=nil, @"Thumbnail image should not be nil");
    XCTAssert([testAlbum.cover.thumbnailImage.urlString isEqualToString:[[[albumDict objectForKey:@"cover"] objectForKey:@"photo200x200xCR"] objectAtIndex:0]], @"Expected thumbnail image = %@. Actual = %@", [[[albumDict objectForKey:@"cover"] objectForKey:@"photo200x200xCR"] objectAtIndex:0], testAlbum.cover.thumbnailImage.urlString);
    
    // test cover's tag
    XCTAssert(testAlbum.cover.tags==nil, @"Tags should be nil because this album's cover");
    XCTAssert(testAlbum.cover.tags.count == 0, @"Tags count should be 0. Actual = %d", testAlbum.cover.tags.count);
    
    // test cover's album
    XCTAssert(testAlbum.cover.albums==nil, @"Cover's Albums should not be nil.");
    XCTAssert(testAlbum.cover.albums.count == 0, @"Expected albums count = 0. Actual = %d", testAlbum.cover.albums.count);

    NSManagedObject *albumManagedObject = [MTLManagedObjectAdapter managedObjectFromModel:testAlbum insertingIntoContext:[NSManagedObjectContext mainContext] error:&error];
    XCTAssert(albumManagedObject != nil, @"Album managed object should not be nil");
    XCTAssert([[albumManagedObject valueForKey:@"albumId"] isEqualToString:[albumDict objectForKey:@"id"]], @"Expected album id = %@. Actual = %@", albumDict[@"id"], [albumManagedObject valueForKey:@"albumId"]);
    NSManagedObjectContext *coverManagedObject = [albumManagedObject valueForKey:@"cover"];
    NSArray *albumCoverManagedObject = [coverManagedObject valueForKey:@"albums"];
    XCTAssert(albumCoverManagedObject.count==testAlbum.cover.albums.count, @"Expected albums count of cover = %d. Actual = %d", testAlbum.cover.albums.count, albumCoverManagedObject.count);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"PBXAlbum" inManagedObjectContext:[NSManagedObjectContext mainContext]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"albumId" ascending:NO]];
    NSArray *results = [[NSManagedObjectContext mainContext] executeFetchRequest:fetchRequest error:&error];
    XCTAssert(results.count==1, @"There should be only 1 album in db at this point. Actual = %d", results.count);
}
@end
