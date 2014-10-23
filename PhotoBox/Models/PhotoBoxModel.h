//
//  PhotoBoxModel.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoBoxModel : MTLModel <MTLJSONSerializing>


@property (nonatomic, strong) NSNumber *totalRows;
@property (nonatomic, strong) NSNumber *totalPages;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *currentRow;
@property (nonatomic, copy) NSString *itemId;

- (id)initWithItemId:(NSString *)itemId;

+ (NSDictionary *)photoBoxJSONKeyPathsByPropertyKeyWithDictionary:(NSDictionary *)dictionary;

+ (NSValueTransformer *)toStringTransformer;
+ (NSValueTransformer *)toNumberTransformer;

@end
