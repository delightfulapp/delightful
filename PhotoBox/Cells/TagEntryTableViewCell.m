//
//  TagEntryTableViewCell.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TagEntryTableViewCell.h"

#import "PureLayout.h"

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
    [super awakeFromNib];
}

- (void)setup {
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView autoPinEdgesToSuperviewEdges];
    
    [self.tagField autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:15];
    [self.tagField autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-15];
    [self.tagField autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:10];
    
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.tagField withOffset:10];
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
