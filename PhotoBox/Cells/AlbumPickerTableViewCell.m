//
//  AlbumPickerTableViewCell.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "AlbumPickerTableViewCell.h"

#import "PureLayout.h"

@interface AlbumPickerTableViewCell ()

@property (nonatomic, strong) UILabel *albumLabel;

@property (nonatomic, strong) UILabel *selectedAlbumLabel;

@end

@implementation AlbumPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setup {
    [self.contentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
    [self.contentView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self withOffset:-30];
    
    [self.albumLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:15];
    [self.albumLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:10];
    
    [self.selectedAlbumLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-10];
    [self.selectedAlbumLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:10];
    [self.selectedAlbumLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.albumLabel withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.albumLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.albumLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.albumLabel withOffset:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)albumLabel {
    if (!_albumLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setText:NSLocalizedString(@"Album", nil)];
        [self.contentView addSubview:label];
        
        _albumLabel = label;
    }
    return _albumLabel;
}

- (UILabel *)selectedAlbumLabel {
    if (!_selectedAlbumLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor colorWithRed:0.746 green:0.746 blue:0.769 alpha:1.000]];
        [label setText:NSLocalizedString(@"Select album", nil)];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:label];
        
        _selectedAlbumLabel = label;
    }
    return _selectedAlbumLabel;
}

- (void)setNoSelectedAlbum {
    [self.selectedAlbumLabel setText:NSLocalizedString(@"Select album", nil)];
}

+ (NSString *)defaultCellReuseIdentifier {
    return @"albumPickerCell";
}

@end
