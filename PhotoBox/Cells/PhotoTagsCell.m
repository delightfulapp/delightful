//
//  PhotoTagsCell.m
//  Delightful
//
//  Created by  on 12/17/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "PhotoTagsCell.h"
#import "SmartTagButton.h"

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

- (void)setTagsDictionary:(NSDictionary *)tagsDictionary {
    if (_tagsDictionary != tagsDictionary) {
        _tagsDictionary = tagsDictionary;
        
        NSMutableArray *tagStrings = [[_tagsDictionary allKeys] mutableCopy];
        if (!self.tagButtons) {
            self.tagButtons = [NSArray array];
        }
        NSMutableArray *tagLabelsCopy = [self.tagButtons mutableCopy];
        for (SmartTagButton *button in self.tagButtons) {
            NSString *tag = [tagStrings firstObject];
            if (tag) {
                [button setTitle:tag forState:UIControlStateNormal];
                BOOL selected = [_tagsDictionary[tag] boolValue];
                [button setTagState:(selected)?TagStateSelected:TagStateNotSelected];
                [tagStrings removeObjectAtIndex:0];
                [button setEnabled:YES];
                [button setHidden:NO];
            } else {
                [button setTitle:nil forState:UIControlStateNormal];
                [button setHidden:YES];
                [button setFrame:CGRectZero];
                [button setEnabled:NO];
            }
        }
        
        for (NSString *tag in tagStrings) {
            SmartTagButton *button = [[SmartTagButton alloc] init];
            [button setTitle:tag forState:UIControlStateNormal];
            [button setAssetIdentifier:self.localAssetIdentifier];
            BOOL selected = [_tagsDictionary[tag] boolValue];
            [button setTagState:(selected)?TagStateSelected:TagStateNotSelected];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button setContentEdgeInsets:UIEdgeInsetsMake(2, 5, 2, 5)];
            [button.layer setCornerRadius:9];
            [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIView *lastView = self.imageView;
    for (UIButton *button in self.tagButtons) {
        if (!button.isEnabled) {
            continue;
        }
        [button sizeToFit];
        CGRect frame = button.frame;
        CGFloat originX = CGRectGetMaxX(lastView.frame) + 5;
        CGFloat originY = CGRectGetMinY(lastView.frame);
        if (originX + frame.size.width + 10 > CGRectGetWidth(self.contentView.frame)) {
            originX = CGRectGetMaxX(self.imageView.frame) + 5;
            originY = CGRectGetMaxY(lastView.frame) + 5;
        }
        if (originX + frame.size.width + 10 > CGRectGetWidth(self.contentView.frame)) {
            originX = CGRectGetMaxX(lastView.frame) + 5;
            originY = CGRectGetMinY(lastView.frame);
            frame.size.width = CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(self.imageView.frame) - 3 * 10;
        }
        
        frame.origin = CGPointMake(originX, originY);
        [button setFrame:frame];
        lastView = button;
    }
}

- (void)didTapButton:(SmartTagButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapButton:)]) {
        [self.delegate cell:self didTapButton:button];
    }
}

@end
