//
//  Album.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Album.h"

#import "Photo.h"

NSString *PBX_allAlbumIdentifier = @"PBX_ALL";

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
    Album *a = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:@{
                                                                               @"id": PBX_allAlbumIdentifier,
                                                                               @"name":NSLocalizedString(@"All Photos", nil),
                                                                               @"cover":@{@"id": @"COVER_PHOTO_ALL_ALBUM", @"filenameOriginal":@""}
                                                                               } error:&error];
    return a;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super class] photoBoxKeyPathsByPropertyKeyWithDictionary:@{@"albumId": @"id"}];
}

+ (NSValueTransformer *)coverJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *JSONDictionary){
        NSMutableDictionary *dictionary = [JSONDictionary mutableCopy];
        [dictionary removeObjectForKey:@"albums"];
        [dictionary removeObjectForKey:@"tags"];
        return [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:dictionary error:NULL];
    } reverseBlock:^id(id model) {
        if (model==nil) {
            return nil;
        }
        return [MTLJSONAdapter JSONDictionaryFromModel:model];
    }];
}

+ (NSValueTransformer *)countJSONTransformer {
    return [[self class] toNumberTransformer];
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
