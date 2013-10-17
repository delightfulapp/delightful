//
//  DownloadCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "DownloadCell.h"

#import "UIView+Additionals.h"

#define DOWNLOAD_CELL_MARGIN 5

@implementation DownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _downloadThumbnailImageView = [[UIImageView alloc] init];
    [_downloadThumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_downloadThumbnailImageView setClipsToBounds:YES];
    _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadNameLabel = [[UILabel alloc] init];
    [_downloadNameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [_downloadNameLabel setBackgroundColor:[UIColor clearColor]];
    [_downloadNameLabel setNumberOfLines:0];
    [_downloadNameLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    [self.contentView addSubview:_downloadNameLabel];
    [self.contentView addSubview:_downloadProgressView];
    [self.contentView addSubview:_downloadThumbnailImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageWidth  = CGRectGetHeight(self.contentView.frame) - DOWNLOAD_CELL_MARGIN*2;
    CGFloat nameWidth = CGRectGetWidth(self.contentView.frame) - 3 * DOWNLOAD_CELL_MARGIN - imageWidth;
    
    [self.downloadThumbnailImageView setFrame:CGRectMake(DOWNLOAD_CELL_MARGIN, DOWNLOAD_CELL_MARGIN, imageWidth, imageWidth)];
    
    self.downloadNameLabel.frame = ({
        CGRect frame = self.downloadNameLabel.frame;
        frame.size.width = nameWidth;
        frame.size.height = self.downloadNameLabel.font.lineHeight;
        frame.origin.x = CGRectGetMaxX(self.downloadThumbnailImageView.frame)+DOWNLOAD_CELL_MARGIN;
        frame.origin.y = CGRectGetMinY(self.downloadThumbnailImageView.frame);
        frame;
    });
    
    self.downloadProgressView.frame = ({
        CGRect frame = self.downloadProgressView.frame;
        frame.origin.x = CGRectGetMinX(self.downloadNameLabel.frame);
        frame.origin.y = CGRectGetMaxY(self.downloadNameLabel.frame) + DOWNLOAD_CELL_MARGIN * 2;
        frame.size.width = nameWidth;
        frame;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - NPRImageDownloaderProgressIndicator

- (void)downloadProgressDidChange:(float)downloadProgress {
    [self.downloadProgressView setProgress:downloadProgress];
}

@end
