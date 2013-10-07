//
//  Album.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "Album.h"

#import "Photo.h"

#import "NSObject+Additionals.h"

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
    return [[super class] photoBoxJSONKeyPathsByPropertyKeyWithDictionary:@{@"albumId": @"id"}];
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

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    NSString *keyType = [[self class] propertyTypeStringForPropertyName:key];
    if ([keyType isEqualToString:@"NSNumber"]) {
        return [[self class] toNumberTransformer];
    } else if ([keyType isEqualToString:@"NSString"]) {
        return [[self class] toStringTransformer];
    }
    return nil;
}

#pragma mark - Managed object serialization

+ (NSString *)managedObjectEntityName {
    return [[self class] photoBoxManagedObjectEntityNameForClassName:NSStringFromClass([self class])];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return [[super class] photoBoxManagedObjectKeyPathsByPropertyKeyWithDictionary:nil];
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"albumId"];
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return @{@"cover": Photo.class, @"photos":Photo.class};
}

@end
