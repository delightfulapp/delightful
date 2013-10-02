//
//  Album.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Album.h"

#import "Photo.h"

@implementation Album

- (id)initWithItemId:(NSString *)itemId{
    self = [super init];
    if (self) {
        _albumId = itemId;
    }
    return self;
}

- (NSURL *)albumCover:(AlbumCoverType)coverType {
    return [NSURL URLWithString:self.cover.thumbnailImage.urlString];
}

- (NSString *)itemId {
    return self.albumId;
}

+ (Album *)allPhotosAlbum {
    NSError *error;
    Album *a = [[Album alloc] initWithDictionary:@{
                                                   @"id": @"ALL",
                                                   @"name":NSLocalizedString(@"All Photos", nil)
                                                   } error:&error];
    return a;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:@{@"albumId": @"id"}];
}

+ (NSValueTransformer *)coverJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[Photo class]];
}

#pragma mark - Managed object serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:nil];
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"albumId"];
}

@end
