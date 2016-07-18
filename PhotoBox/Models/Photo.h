//
//  Photo.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

@import CoreLocation;
#import "PhotoBoxModel.h"
#import "PhotoBoxImage.h"

@interface Photo : PhotoBoxModel

@property (nonatomic, copy, readonly) NSNumber *dateTaken;
@property (nonatomic, copy, readonly) NSNumber *dateTakenDay;
@property (nonatomic, copy, readonly) NSNumber *dateTakenMonth;
@property (nonatomic, copy, readonly) NSNumber *dateTakenYear;
@property (nonatomic, copy, readonly) NSNumber *dateUploaded;
@property (nonatomic, copy, readonly) NSNumber *dateUploadedDay;
@property (nonatomic, copy, readonly) NSNumber *dateUploadedMonth;
@property (nonatomic, copy, readonly) NSNumber *dateUploadedYear;
@property (nonatomic, copy, readonly) NSString *dateSortByDay;
@property (nonatomic, copy, readonly) NSString *photoDescription;
@property (nonatomic, copy, readonly) NSString *exifCameraMake;
@property (nonatomic, copy, readonly) NSString *exifCameraModel;
@property (nonatomic, copy, readonly) NSString *exifExposureTime;
@property (nonatomic, copy, readonly) NSNumber *exifFNumber;
@property (nonatomic, copy, readonly) NSNumber *exifFocalLength;
@property (nonatomic, copy, readonly) NSNumber *exifISOSpeed;
@property (nonatomic, copy, readonly) NSString *filenameOriginal;
@property (nonatomic, copy, readonly) NSString *photoHash;
@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSNumber *latitude;
@property (nonatomic, copy, readonly) NSString *license;
@property (nonatomic, copy, readonly) NSNumber *longitude;
@property (nonatomic, copy, readonly) NSString *photoId;
@property (nonatomic, copy, readonly) NSURL *pathOriginal;
@property (nonatomic, copy, readonly) NSURL *pathBase;
@property (nonatomic, copy, readonly) NSNumber *size;
@property (nonatomic, copy, readonly) NSArray *tags;
@property (nonatomic, copy, readonly) NSArray *albums;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSDate *timestamp;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSNumber *views;
@property (nonatomic, copy, readonly) NSNumber *width;
@property (nonatomic, copy, readonly) NSNumber *height;
@property (nonatomic, copy, readonly) NSString *dimension;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo320x320;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo640x640;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo100x100;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo200x200;

@property (nonatomic, copy, readonly) PhotoBoxImage *thumbnailImage;
@property (nonatomic, copy, readonly) PhotoBoxImage *normalImage;
@property (nonatomic, copy, readonly) PhotoBoxImage *originalImage;
@property (nonatomic, copy, readonly) PhotoBoxImage *pathBaseImage;

@property (nonatomic, copy, readonly) NSString *dateMonthYearTakenString;
@property (nonatomic, copy, readonly) NSDate *dateUploadedDate;
@property (nonatomic, copy, readonly) NSDate *dateTakenDate;
@property (nonatomic, copy, readonly) NSString *dateTakenString;
@property (nonatomic, copy, readonly) NSString *dateUploadedString;
@property (nonatomic, copy, readonly) NSString *dateTimeTakenLocalizedString;

@property (nonatomic, copy, readonly) NSArray *fetchedIn;
@property (nonatomic, copy, readonly) NSDate *downloadedDate;
@property (nonatomic, copy, readonly) NSString *latitudeLongitudeString;
@property (nonatomic, copy, readonly) CLLocation *clLocation;
@property (nonatomic, strong) UIImage *asAlbumCoverImage;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSURL *asAlbumCoverURL;


@end
