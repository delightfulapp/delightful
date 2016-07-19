//
//  UploadDescriptionTableViewCell.m
//  Delightful
//
//  Created by  on 1/5/15.
//  Copyright (c) 2015 Touches. All rights reserved.
//

#import "UploadDescriptionTableViewCell.h"
#import "PureLayout.h"
#import "UIColor+Additionals.h"

@interface UploadDescriptionTableViewCell ()

@property (nonatomic, strong) DescriptionTextView *textView;

@end

@implementation UploadDescriptionTableViewCell

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
    
    [self.textView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView withOffset:10];
    [self.textView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-15];
    [self.textView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.contentView withOffset:10];
    [self.contentView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.textView withOffset:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (DescriptionTextView *)textView {
    if (!_textView) {
        DescriptionTextView *textView = [[DescriptionTextView alloc] initForAutoLayout];
        [textView setFont:[UIFont systemFontOfSize:17]];
        [self.contentView addSubview:textView];
        _textView  = textView;
    }
    return _textView;
}

+ (NSString *)defaultCellReuseIdentifier {
    return @"uploadDescriptionCell";
}

@end

@implementation DescriptionTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *placeholderLabel = [[UILabel alloc] initForAutoLayout];
        [self addSubview:placeholderLabel];
        [placeholderLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(7, 5, 0, 5) excludingEdge:ALEdgeBottom];
        [placeholderLabel setText:NSLocalizedString(@"Description (Optional)", nil)];
        [placeholderLabel setTextColor:[UIColor lightGrayTextColor]];
        [placeholderLabel setFont:[UIFont systemFontOfSize:17]];
        self.placeholderLabel = placeholderLabel;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 100);
}

- (void)textViewDidChangeNotification:(NSNotification *)notification {
    [self.placeholderLabel setHidden:(self.text.length>0)];
}

@end
