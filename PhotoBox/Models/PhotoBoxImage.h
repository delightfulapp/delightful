//
//  Image.h
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

@class Photo;

@interface PhotoBoxImage : NSObject

@property (nonatomic, weak) Photo *photo;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithArray:(NSArray *)array;

@end
