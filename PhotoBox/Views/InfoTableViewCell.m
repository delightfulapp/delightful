//
//  InfoTableViewCell.m
//  Delightful
//
//  Created by Nico Prananta on 5/18/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "InfoTableViewCell.h"

@interface InfoTableViewCell ()

@property (nonatomic, strong) NSString *thisTitle;
@property (nonatomic, strong) NSString *thisDetail;


@end

@implementation InfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self.infoTextLabel setText:nil];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.infoTextLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setText:(NSString *)text detail:(NSString *)detail {
    BOOL textChanged = NO;
    BOOL detailChanged = NO;
    
    if (_thisDetail != detail) {
        _thisDetail = detail;
        detailChanged = YES;
    }
    
    if (_thisTitle != text) {
        _thisTitle = text;
        textChanged = YES;
    }
    
    if (textChanged || detailChanged) {
        if (!text) {
            text = @"";
        }
        if (!detail) {
            detail = @"";
        }
        
        NSString *combined = [NSString stringWithFormat:@"%@ %@", text, detail];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:combined];
        if (text.length > 0) {
            [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:[combined rangeOfString:text]];
        }
        if (detail.length > 0) {
            [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[combined rangeOfString:detail]];
        }
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, combined.length)];
        
        [self.infoTextLabel setAttributedText:attr];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.infoTextLabel setPreferredMaxLayoutWidth:self.infoTextLabel.frame.size.width];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, self.infoTextLabel.intrinsicContentSize.height + 2*CGRectGetMinY(self.infoTextLabel.frame));
}

@end
