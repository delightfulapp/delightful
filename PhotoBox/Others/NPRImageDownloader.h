//
//  OriginalImageDownloader.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bolts.h"

@class Photo;

extern NSString *const NPRImageDownloadDidStartNotification;
extern NSString *const NPRImageDownloadDidFinishNotification;

@interface NPRImageDownloaderOperation : NSObject

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger taskIdentifier;
@property (nonatomic, strong) Photo *photo;

@end

@protocol NPRImageDownloaderDelegate <NSObject>

- (void)didStartDownloadOperation:(id)operation;
- (void)didFailDownloadOperation:(id)operation atIndex:(NSInteger)index;
- (void)didFinishDownloadOperation:(id)operation atIndex:(NSInteger)index;
- (void)didProgress:(float)progress forOperation:(id)operation atIndex:(NSInteger)index;

@end

@class Photo;

@interface NPRImageDownloader : NSObject <NSURLSessionDelegate>

@property (nonatomic, weak) id<NPRImageDownloaderDelegate> delegate;

@property (nonatomic, copy) id(^downloadViewControllerInitBlock)();

+ (instancetype)sharedDownloader;
- (void)showDownloads;
- (BOOL)queueImageURL:(NSURL *)URL thumbnail:(UIImage *)image;
- (BOOL)queuePhoto:(Photo *)photo thumbnail:(UIImage *)image;
- (NSInteger)numberOfDownloads;
- (id)downloadOperationAtIndex:(NSInteger)index;
- (BOOL)isDownloadingImageAtURL:(NSURL *)URL;
- (BFTask *)downloadOriginalPhoto:(Photo *)photo;


@end
