//
//  Photo.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

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
@property (nonatomic, copy, readonly) NSString *latitude;
@property (nonatomic, copy, readonly) NSString *license;
@property (nonatomic, copy, readonly) NSString *longitude;
@property (nonatomic, copy, readonly) NSString *photoId;
@property (nonatomic, copy, readonly) NSURL *pathOriginal;
@property (nonatomic, copy, readonly) NSNumber *size;
@property (nonatomic, copy, readonly) NSArray *tags;
@property (nonatomic, copy, readonly) NSArray *albums;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSDate *timestamp;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSNumber *views;
@property (nonatomic, copy, readonly) NSNumber *width;
@property (nonatomic, copy, readonly) NSNumber *height;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo200x200xCR;
@property (nonatomic, copy, readonly) PhotoBoxImage *photo640x640;

@property (nonatomic, copy, readonly) PhotoBoxImage *thumbnailImage;
@property (nonatomic, copy, readonly) PhotoBoxImage *normalImage;
@property (nonatomic, copy, readonly) PhotoBoxImage *originalImage;
@property (nonatomic, readonly) NSString *dateTakenString;
@property (nonatomic, readonly) NSString *dateMonthYearTakenString;

@end
