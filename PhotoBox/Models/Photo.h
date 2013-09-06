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

@property (nonatomic, assign) int dateTaken;
@property (nonatomic, assign) int dateTakenDay;
@property (nonatomic, assign) int dateTakenMonth;
@property (nonatomic, assign) int dateTakenYear;
@property (nonatomic, assign) int dateUploaded;
@property (nonatomic, assign) int dateUploadedDay;
@property (nonatomic, assign) int dateUploadedMonth;
@property (nonatomic, assign) int dateUploadedYear;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *exifCameraMake;
@property (nonatomic, strong) NSString *exifCameraModel;
@property (nonatomic, strong) NSString *exifExposureTime;
@property (nonatomic, strong) NSString *exifFNumber;
@property (nonatomic, strong) NSString *exifFocalLength;
@property (nonatomic, strong) NSString *exifISOSpeed;
@property (nonatomic, strong) NSString *filenameOriginal;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSString *pathOriginal;
@property (nonatomic, assign) int size;
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) int views;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, readonly) NSString *dateTakenString;
@property (nonatomic, readonly) NSString *dateMonthYearTakenString;

@property (nonatomic, strong) PhotoBoxImage *thumbnailImage;
@property (nonatomic, strong) PhotoBoxImage *normalImage;
@property (nonatomic, strong) PhotoBoxImage *originalImage;
@property (nonatomic, readonly) NSArray *photo200x200xCR;
@property (nonatomic, readonly) NSArray *photo640x640;

@end
