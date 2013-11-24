//
//  AlbumRowCell.h
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DelightfulRowCell.h"

@interface AlbumRowCell : DelightfulRowCell

- (NSAttributedString *)attributedTextForAlbumName:(NSString *)name count:(NSInteger)count;

@end
