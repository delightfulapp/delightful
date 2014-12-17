//
//  PhotoTagsCell.m
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotoTagsCell.h"

@interface PhotoTagsCell ()

@property (nonatomic, copy) NSArray *tagButtons;

@end

@implementation PhotoTagsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        self.imageViewSize = CGSizeMake(80, 80);
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.imageView setClipsToBounds:YES];
        
        self.imageView.frame = ({
            CGRect frame = self.imageView.frame;
            frame.size = self.imageViewSize;
            frame.origin = CGPointMake(10, 10);
            frame;
        });
        
        [self.contentView.layer setBorderWidth:1];
        [self.contentView.layer setBorderColor:[[UIColor colorWithWhite:0.850 alpha:1.000] CGColor]];
    }
    return self;
}

- (void)setTags:(NSArray *)tags {
    if (_tags != tags) {
        _tags = tags;
        
        NSMutableArray *tagsCopies = [NSMutableArray arrayWithArray:_tags];
        if (!self.tagButtons) {
            self.tagButtons = [NSArray array];
        }
        NSMutableArray *tagLabelsCopy = [self.tagButtons mutableCopy];
        for (UIButton *button in _tagButtons) {
            NSString *tag = [tagsCopies firstObject];
            if (tag) {
                [button setTitle:tag forState:UIControlStateNormal];
                [tagsCopies removeObjectAtIndex:0];
            } else {
                [button setHidden:YES];
                [tagLabelsCopy removeObject:button];
            }
        }
        
        for (NSString *tag in tagsCopies) {
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:tag forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button setContentEdgeInsets:UIEdgeInsetsMake(2, 5, 2, 5)];
            [button setBackgroundColor:[UIColor colorWithRed:0.255 green:0.529 blue:0.835 alpha:1.000]];
            [button.layer setCornerRadius:9];
            [self.contentView addSubview:button];
            [tagLabelsCopy addObject:button];
        }
        
        self.tagButtons = tagLabelsCopy;
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = ({
        CGRect frame = self.imageView.frame;
        frame.size = self.imageViewSize;
        frame.origin = CGPointMake(10, 10);
        frame;
    });
    
    CGFloat width = CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(self.imageView.frame) - 3 * 10;
    UIButton *firstTag = [self.tagButtons firstObject];
    [firstTag sizeToFit];
    firstTag.frame = ({
        CGRect frame = firstTag.frame;
        frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
        frame.origin.y = CGRectGetMinY(self.imageView.frame);
        if (frame.size.width > width) {
            frame.size.width = width;
        }
        frame;
    });
    UIView *lastView = firstTag;
    int i = 0;
    for (UIButton *button in self.tagButtons) {
        if (i == 0) {
            i++;
            continue;
        }
        [button sizeToFit];
        CGRect frame = button.frame;
        CGFloat originX = CGRectGetMaxX(lastView.frame) + 5;
        CGFloat originY = CGRectGetMinY(lastView.frame);
        if (originX + frame.size.width + 10 > CGRectGetWidth(self.contentView.frame)) {
            originX = CGRectGetMinX(firstTag.frame);
            originY = CGRectGetMaxY(lastView.frame) + 5;
        }
        frame.origin = CGPointMake(originX, originY);
        [button setFrame:frame];
        lastView = button;
    }
}

@end
