//
//  PhotoCell.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumCell.h"

@interface PhotoCell : PhotoBoxCell

@property (weak, nonatomic) IBOutlet UILabel *photoTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateTitle;
@property (weak, nonatomic) IBOutlet UIView *photoTitleBackgroundView;
@property (assign, nonatomic) BOOL showTitles;

@end
