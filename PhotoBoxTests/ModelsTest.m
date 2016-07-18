//
//  ModelsTest.m
//  Delightful
//
//  Created by Nico Prananta on 7/18/16.
//  Copyright © 2016 DelightfulDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Photo.h"
#import "Album.h"
#import "Tag.h"
#import "XCTestCase+Additionals.h"

@interface ModelsTest : XCTestCase

@end

@implementation ModelsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPhoto {
    NSDictionary *dictionary = [self objectFromJSONFile:@"photo"];
    NSError *error = nil;
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:dictionary error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(photo);
    XCTAssertTrue([photo.photoId isEqualToString:@"bd"]);
    XCTAssertEqual([photo.dateTakenDay intValue], 3);
    XCTAssertEqual((int)[photo.tags count], 4);
    XCTAssertEqual((int)[photo.albums count], 2);
}

- (void)testAlbum {
    NSDictionary *dictionary = [self objectFromJSONFile:@"album"];
    NSError *error = nil;
    Album *album = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:dictionary error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(album);
    XCTAssertTrue([album.itemId isEqualToString:@"3"]);
    XCTAssertTrue([album.albumCover.photoId isEqualToString:@"5"]);
    XCTAssertTrue([album.coverURL.absoluteString isEqualToString:@"http://trovebox.dev/photos/custom/201607/iu-8-984303_200x200xCR.jpg"]);
    XCTAssertEqual([[album count] intValue], 2);
}

- (void)testTag {
    NSDictionary *dictionary = [self objectFromJSONFile:@"tags"];
    NSArray *tags = dictionary[@"result"];
    NSError *error = nil;
    Tag *tag = [MTLJSONAdapter modelOfClass:[Tag class] fromJSONDictionary:tags[0] error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag.tagId isEqualToString:@"2016"]);
    XCTAssertEqual([tag.count intValue], 6);
}


@end
