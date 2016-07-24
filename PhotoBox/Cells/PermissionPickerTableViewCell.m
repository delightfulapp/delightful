//
//  PermissionPickerTableViewCell.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PermissionPickerTableViewCell.h"

#import "PureLayout.h"

@interface PermissionPickerTableViewCell ()

@property (nonatomic, strong) UILabel *permissionLabel;

@property (nonatomic, strong) UISwitch *permissionSwitch;

@end

@implementation PermissionPickerTableViewCell

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
    [self.contentView autoPinEdgesToSuperviewEdges];
    
    [self.permissionLabel setText:NSLocalizedString(@"Private", nil)];
    [self.permissionSwitch setOn:YES];
    
    [self.permissionLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:15];
    [self.permissionLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.permissionSwitch withOffset:-10 relation:NSLayoutRelationLessThanOrEqual];
    [self.permissionLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.permissionSwitch];
    
    [self.permissionSwitch autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-15];
    [self.permissionSwitch autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:5];
    
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.permissionSwitch withOffset:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)permissionLabel {
    if (!_permissionLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setText:NSLocalizedString(@"Private photos", nil)];
        [self.contentView addSubview:label];
        
        _permissionLabel = label;
    }
    return _permissionLabel;
}

- (UISwitch *)permissionSwitch {
    if (!_permissionSwitch) {
        UISwitch *sw = [[UISwitch alloc] init];
        [sw setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:sw];
        
        _permissionSwitch = sw;
    }
    
    return _permissionSwitch;
}

+ (NSString *)defaultCellReuseIdentifier {
    return @"permissionPickerCell";
}

@end
