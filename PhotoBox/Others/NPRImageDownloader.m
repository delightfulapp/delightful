//
//  OriginalImageDownloader.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRImageDownloader.h"
#import <AFImageRequestOperation.h>
#import "Photo.h"
#import "DownloadedImageManager.h"

NSString *const NPRImageDownloadDidStartNotification = @"jp.touches.nprimagedownload.notification-didStart";
NSString *const NPRImageDownloadDidFinishNotification = @"jp.touches.nprimagedownload.notification-didFinish";

@interface NPRImageDownloader ()

@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSMutableArray *downloadURLs;
@property (nonatomic, strong) NSOperationQueue *downloadingQueue;

@end

@implementation NPRImageDownloader

+ (instancetype)sharedDownloader {
    static NPRImageDownloader *_sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDownloader = [[NPRImageDownloader alloc] init];
        _sharedDownloader.downloads = [[NSMutableArray alloc] init];
        _sharedDownloader.downloadURLs = [[NSMutableArray alloc] init];
        _sharedDownloader.downloadingQueue = [[NSOperationQueue alloc] init];
    });
    
    return _sharedDownloader;
}

- (void)showDownloads {
    if (self.downloadViewControllerInitBlock) {
        id vc = self.downloadViewControllerInitBlock();
        if (vc) {
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            UIViewController *rootVC = window.rootViewController;
            [rootVC presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (BOOL)queueImageURL:(NSURL *)URL thumbnail:(UIImage *)image {
    return [self queuePhoto:nil URL:URL thumbnail:image];
}

- (BOOL)queuePhoto:(Photo *)photo thumbnail:(UIImage *)image {
    return [self queuePhoto:photo URL:photo.pathOriginal thumbnail:image];
}

- (BOOL)queuePhoto:(Photo *)photo URL:(NSURL *)URL thumbnail:(UIImage *)image {
    if ([self isDownloadingImageAtURL:URL]) {
        PBX_LOG(@"Cancel download");
        return NO;
    }
    
    __weak NPRImageDownloader *weakSelf = self;
    NPRImageDownloaderOperation *downloadOperation = [[NPRImageDownloaderOperation alloc] initWithURL:URL thumbnail:image progress:^(NPRImageDownloaderOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NPRImageDownloaderOperation *strongOperation = operation;
        if (weakSelf) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didProgress:forOperation:atIndex:)]) {
                [weakSelf.delegate didProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead) forOperation:strongOperation atIndex:[weakSelf indexOfOperation:strongOperation]];
            }
        }
    } success:^(NPRImageDownloaderOperation *operation, NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NPRImageDownloaderOperation *strongOperation = operation;
        if (weakSelf) {
            NSInteger index = [weakSelf indexOfOperation:strongOperation];
            [weakSelf removeOperation:strongOperation URL:request.URL];
            if (photo) {
                [[DownloadedImageManager sharedManager] addPhoto:photo];
            }
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFinishDownloadOperation:atIndex:)]) {
                [weakSelf.delegate didFinishDownloadOperation:strongOperation atIndex:index];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NPRImageDownloadDidFinishNotification object:nil];
    } failure:^(NPRImageDownloaderOperation *operation, NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NPRImageDownloaderOperation *strongOperation = operation;
        if (weakSelf) {
            NSInteger index = [weakSelf indexOfOperation:strongOperation];
            [weakSelf removeOperation:strongOperation URL:request.URL];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFailDownloadOperation:atIndex:)]) {
                [weakSelf.delegate didFailDownloadOperation:strongOperation atIndex:index];
            }
        }
    }];
    
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        [self.downloads addObject:downloadOperation];
        [self.downloadURLs addObject:URL];
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NPRImageDownloadDidStartNotification object:nil];
    }
    
    [self.downloadingQueue addOperation:downloadOperation.operation];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStartDownloadOperation:)]) {
        [self.delegate didStartDownloadOperation:downloadOperation];
    }
    
    return YES;
}

- (NSInteger)numberOfDownloads {
    @synchronized(self) {
        return self.downloads.count;
    }
}

- (NSInteger)indexOfOperation:(id)operation {
    @synchronized(self) {
        return [self.downloads indexOfObject:operation];
    }
}

- (id)downloadOperationAtIndex:(NSInteger)index {
    @synchronized(self){
        id operation = [self.downloads objectAtIndex:index];
        return operation;
    }
}

- (BOOL)isDownloadingImageAtURL:(NSURL *)URL {
    @synchronized(self) {
        return [self.downloadURLs containsObject:URL]?YES:NO;
    }
}

- (void)removeOperation:(id)operation URL:(NSURL *)URL {
    @synchronized(self) {
        PBX_LOG(@"Removing 1 of %d operations.", self.downloadURLs.count);
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        [self.downloads removeObject:operation];
        [self.downloadURLs removeObject:URL];
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
    }
}

@end

@implementation NPRImageDownloaderOperation

- (NSString *)name {
    return self.URL.lastPathComponent;
}

- (id)initWithURL:(NSURL *)URL thumbnail:(UIImage *)thumbnail progress:(void (^)(NPRImageDownloaderOperation*, NSUInteger, long long, long long))progress success:(void (^)(NPRImageDownloaderOperation *operation, NSURLRequest *, NSHTTPURLResponse *, UIImage *))success failure:(void (^)(NPRImageDownloaderOperation *operation, NSURLRequest *, NSHTTPURLResponse *, NSError *))failure{
    if (self = [super init]) {
        _thumbnail = thumbnail;
        _URL = URL;
        [self setOperationWithURL:URL progress:progress success:success failure:failure];
    }
    return self;
}

- (void)setOperationWithURL:(NSURL *)URL progress:(void (^)(NPRImageDownloaderOperation*,NSUInteger, long long, long long))progress success:(void (^)(NPRImageDownloaderOperation *, NSURLRequest *, NSHTTPURLResponse *, UIImage *))success failure:(void (^)(NPRImageDownloaderOperation *, NSURLRequest *, NSHTTPURLResponse *, NSError *))failure{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    __weak NPRImageDownloaderOperation *weakOperation = self;
    self.operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        if (image) {
            PBX_LOG(@"Writing image to photos album");
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        success(weakOperation, request, response, image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        failure(weakOperation, request, response, error);
    }];
    
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progress(weakOperation, bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
}

- (BOOL)isEqual:(NPRImageDownloaderOperation *)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if ([object.URL.absoluteURL isEqual:self.URL.absoluteURL]) {
        return YES;
    }
    return NO;
}

@end