//
//  AlbumRowCell.h
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxCell.h"

@interface DelightfulRowCell : PhotoBoxCell

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIView *lineView;

@end
