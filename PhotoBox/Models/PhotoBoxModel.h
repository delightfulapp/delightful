//
//  PhotoBoxModel.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MTLModel.h>

@interface PhotoBoxModel : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>


@property (nonatomic, strong) NSNumber *totalRows;
@property (nonatomic, strong) NSNumber *totalPages;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *currentRow;
@property (nonatomic, copy) NSString *itemId;

- (id)initWithItemId:(NSString *)itemId;

+ (NSString *)photoBoxManagedObjectEntityNameForClassName:(NSString *)className;

+ (NSDictionary *)photoBoxJSONKeyPathsByPropertyKeyWithDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)photoBoxManagedObjectKeyPathsByPropertyKeyWithDictionary:(NSDictionary *)dictionary;

+ (NSValueTransformer *)toStringTransformer;
+ (NSValueTransformer *)toNumberTransformer;

@end
