//
//  OriginalImageDownloader.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/17/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NPRImageDownloader.h"
#import "Photo.h"
#import "DownloadedImageManager.h"
#import <AFNetworking/AFNetworking.h>

NSString *const NPRImageDownloadDidStartNotification = @"jp.touches.nprimagedownload.notification-didStart";
NSString *const NPRImageDownloadDidFinishNotification = @"jp.touches.nprimagedownload.notification-didFinish";

@interface NPRImageDownloader () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSMutableArray *downloadURLs;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NPRImageDownloader

+ (instancetype)sharedDownloader {
    static NPRImageDownloader *_sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDownloader = [[NPRImageDownloader alloc] init];
        _sharedDownloader.downloads = [[NSMutableArray alloc] init];
        _sharedDownloader.downloadURLs = [[NSMutableArray alloc] init];
        _sharedDownloader.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:_sharedDownloader delegateQueue:[NSOperationQueue mainQueue]];
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
    
    NPRImageDownloaderOperation *downloadOperation = [[NPRImageDownloaderOperation alloc] init];
    downloadOperation.URL = URL;
    downloadOperation.thumbnail = image;
    downloadOperation.name = URL.lastPathComponent;
    downloadOperation.photo = photo;
    
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:URL];
    /*
    if (error) {
        if (weakSelf) {
            NSInteger index = [weakSelf indexOfOperation:downloadOperation];
            [weakSelf removeOperation:downloadOperation URL:URL];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFailDownloadOperation:atIndex:)]) {
                [weakSelf.delegate didFailDownloadOperation:downloadOperation atIndex:index];
            }
        }
    } else {
        if (weakSelf) {
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *image = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            NSInteger index = [weakSelf indexOfOperation:downloadOperation];
            [weakSelf removeOperation:downloadOperation URL:URL];
            if (photo) {
                [[DownloadedImageManager sharedManager] addPhoto:photo];
            }
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFinishDownloadOperation:atIndex:)]) {
                [weakSelf.delegate didFinishDownloadOperation:downloadOperation atIndex:index];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NPRImageDownloadDidFinishNotification object:nil];
    }
     */
    downloadOperation.taskIdentifier = downloadTask.taskIdentifier;
    
    @synchronized(self){
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        [self.downloads addObject:downloadOperation];
        [self.downloadURLs addObject:URL];
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NPRImageDownloadDidStartNotification object:nil];
    }
    
    [downloadTask resume];
    
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

- (id)downloadOperationWithTaskIdentifier:(NSUInteger)taskIdentifier {
    @synchronized(self){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %ld", NSStringFromSelector(@selector(taskIdentifier)), taskIdentifier];
        NSArray *operations = [self.downloads filteredArrayUsingPredicate:predicate];
        return [operations firstObject];
    }
}

- (BOOL)isDownloadingImageAtURL:(NSURL *)URL {
    @synchronized(self) {
        return [self.downloadURLs containsObject:URL]?YES:NO;
    }
}

- (void)removeOperation:(id)operation URL:(NSURL *)URL {
    @synchronized(self) {
        PBX_LOG(@"Removing 1 of %lu operations.", (unsigned long)self.downloadURLs.count);
        [self willChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
        [self.downloads removeObject:operation];
        [self.downloadURLs removeObject:URL];
        [self didChangeValueForKey:NSStringFromSelector(@selector(numberOfDownloads))];
    }
}

- (BFTask *)downloadOriginalPhoto:(Photo *)photo {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:photo.pathOriginal completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [taskCompletionSource setError:error];
        } else {
            UIImage *image = [UIImage imageWithData:data];
            [taskCompletionSource setResult:image];
        }
    }];
    [dataTask resume];
    return taskCompletionSource.task;
}

#pragma mark - Session Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NPRImageDownloaderOperation *downloadOperation = [self downloadOperationWithTaskIdentifier:downloadTask.taskIdentifier];
    NSInteger index = [self indexOfOperation:downloadOperation];
    [self removeOperation:downloadOperation URL:downloadTask.originalRequest.URL];
    if (downloadOperation.photo) {
        [[DownloadedImageManager sharedManager] addPhoto:downloadOperation.photo];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDownloadOperation:atIndex:)]) {
        [self.delegate didFinishDownloadOperation:downloadOperation atIndex:index];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NPRImageDownloadDidFinishNotification object:nil];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NPRImageDownloaderOperation *downloadOperation = [self downloadOperationWithTaskIdentifier:task.taskIdentifier];
    NSInteger index = [self indexOfOperation:downloadOperation];
    [self removeOperation:downloadOperation URL:task.originalRequest.URL];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailDownloadOperation:atIndex:)]) {
        [self.delegate didFailDownloadOperation:downloadOperation atIndex:index];
    }
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NPRImageDownloaderOperation *operation = [self downloadOperationWithTaskIdentifier:downloadTask.taskIdentifier];
    if (operation && self.delegate && [self.delegate respondsToSelector:@selector(didProgress:forOperation:atIndex:)]) {
        [self.delegate didProgress:((float)totalBytesWritten/(float)totalBytesExpectedToWrite) forOperation:operation atIndex:[self indexOfOperation:operation]];
    }
}

@end

@implementation NPRImageDownloaderOperation
@end
