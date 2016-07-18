//
//  AlbumRowCell.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumRowCell.h"

#import "Album.h"

#import "PureLayout.h"

#import "UIImageView+Additionals.h"

#import "UIView+Additionals.h"

@interface AlbumRowCell ()

@property (nonatomic, weak) UIView *selectedView;

@property (nonatomic, weak) UIView *roundedMaskView;

@end


@implementation AlbumRowCell

@synthesize item = _item;

- (void)setup {
    [super setup];
    
    [self setupSelectedViewConstrains];
    
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setNumberOfLines:4];
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.lineLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // some weird bug in iOS 7 where the image view is not circled if we call setCornerRadius directly here.
    __weak UIImageView *selfieImageView = self.cellImageView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [selfieImageView.layer setCornerRadius:CGRectGetWidth(selfieImageView.frame)/2];
    });
}

#pragma mark - Setters

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Album *album = (Album *)item;
        NSURL *imageURL = [album coverURL];
        
        [self.cellImageView sd_setImageWithURL:imageURL completed:nil];
        
        [self.textLabel setAttributedText:[self attributedTextForAlbumName:album.name count:album.count.intValue]];
    }
}

- (void)setHighlighted:(BOOL)selected {
    [super setHighlighted:selected];
    
    [self.selectedView setHidden:!selected];
}

#pragma mark - Override constrains

- (void)setupTextLabelConstrains {
    [self.textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cellImageView withOffset:10];
    [self.textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.contentView withOffset:-80];
    [self.textLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

- (void)setupSelectedViewConstrains {
    [self.selectedView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    [self.selectedView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.selectedView autoCenterInSuperview];
}

#pragma mark - Getters

- (UIView *)selectedView {
    if (!_selectedView) {
        _selectedView = [self addSubviewClass:[UIView class]];
        [_selectedView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_selectedView setBackgroundColor:[UIColor colorWithWhite:1.000 alpha:0.180]];
        [_selectedView setHidden:YES];
    }
    return _selectedView;
}

- (NSAttributedString *)attributedTextForAlbumName:(NSString *)name count:(NSInteger)count {
    NSString *photos = [NSString stringWithFormat:@"%d %@", (int)count, NSLocalizedString(@"photos", nil)];
    NSString *string = [NSString stringWithFormat:@"%@\n%@", name, photos];
    
    UIFont* font = [UIFont boldSystemFontOfSize:12];
    
    UIColor* textColor = [UIColor blackColor];
    
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : textColor,
                             NSFontAttributeName : font};
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]
                                      initWithString:string attributes:attrs];
    
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:[string rangeOfString:photos]];
    return attrString;
}

- (CAShapeLayer *)lineShadowLayer {
    return nil;
}

@end
