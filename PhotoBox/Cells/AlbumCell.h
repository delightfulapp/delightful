//
//  AlbumCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxCell.h"

@interface AlbumCell : PhotoBoxCell

@property (weak, nonatomic) IBOutlet UILabel *albumTitle;
@property (weak, nonatomic) IBOutlet UIView *albumTitleBackgroundView;
@end
