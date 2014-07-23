//
//  TagEntryTableViewCell.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "TagEntryTableViewCell.h"

#import <UIView+AutoLayout.h>

@interface TagEntryTableViewCell ()

@property (nonatomic, strong) UITextField *tagField;
@property (nonatomic, strong) UIButton *tagPickerButton;

@end

@implementation TagEntryTableViewCell

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
}

- (void)setup {
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    [self.tagField autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:15];
    [self.tagField autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.tagPickerButton];

    [self.tagPickerButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.tagField withOffset:10];
    [self.tagPickerButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-15];
    [self.tagPickerButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:10];
    
    [self.tagField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.tagPickerButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.tagPickerButton withOffset:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UITextField *)tagField {
    if (!_tagField) {
        UITextField *textfield = [[UITextField alloc] init];
        [textfield setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textfield setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textfield setTranslatesAutoresizingMaskIntoConstraints:NO];
        [textfield setPlaceholder:NSLocalizedString(@"Optional comma separated list", nil)];
        [self.contentView addSubview:textfield];
        
        _tagField = textfield;
    }
    return _tagField;
}

- (UIButton *)tagPickerButton {
    if (!_tagPickerButton) {
        UIButton *pickerButton = [[UIButton alloc] init];
        [pickerButton setImage:[[UIImage imageNamed:@"right.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [pickerButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:pickerButton];
        
        _tagPickerButton = pickerButton;
    }
    return _tagPickerButton;
}

+ (NSString *)defaultCellReuseIdentifier {
    return @"tagsPickerCell";
}

@end
