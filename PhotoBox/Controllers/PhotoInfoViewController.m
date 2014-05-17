//
//  PhotoInfoViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/29/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoInfoViewController.h"

#import "Photo.h"
#import "UIView+Additionals.h"

#import "LocationManager.h"

#define PHOTO_INFO_FONT_SIZE 12
#define PHOTO_INFO_CLOSE_OFFSET 50

@interface PhotoInfoViewController () {
    BOOL isClosing;
}

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *cameraDataSectionRows;

@end

@implementation PhotoInfoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];

    self.sections = @[NSLocalizedString(@"Camera Data", nil), NSLocalizedString(@"Tags", nil)];
    
    self.cameraDataSectionRows = @[
                                   @[NSLocalizedString(@"Camera Make", nil), NSStringFromSelector(@selector(exifCameraMake))],
                                   @[NSLocalizedString(@"Camera Model", nil), NSStringFromSelector(@selector(exifCameraModel))],
                                   @[NSLocalizedString(@"Exposure Time", nil), NSStringFromSelector(@selector(exifExposureTime))],
                                   @[NSLocalizedString(@"F Number", nil), NSStringFromSelector(@selector(exifFNumber))],
                                   @[NSLocalizedString(@"Focal Length", nil), NSStringFromSelector(@selector(exifFocalLength))],
                                   @[NSLocalizedString(@"ISO Time", nil), NSStringFromSelector(@selector(exifISOSpeed))],
                                   @[NSLocalizedString(@"Dimension", nil), NSStringFromSelector(@selector(dimension))],
                                   @[NSLocalizedString(@"File Name", nil), NSStringFromSelector(@selector(filenameOriginal))],
                                   @[NSLocalizedString(@"Date Taken", nil), NSStringFromSelector(@selector(dateTakenString))],
                                   @[NSLocalizedString(@"Location", nil), NSStringFromSelector(@selector(latitudeLongitudeString))]
                                   ];
    
    CGFloat cellHeight = [self tableView:nil heightForRowAtIndexPath:nil];
    [self.tableView setContentInset:UIEdgeInsetsMake(CGRectGetHeight(self.tableView.frame)-cellHeight*(self.cameraDataSectionRows.count+1), 0, 0, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
    NSNumber *latitude = [self.photo valueForKey:@"latitude"];
    NSNumber *longitude = [self.photo valueForKey:@"longitude"];
    if (latitude && ![latitude isKindOfClass:[NSNull class]] && longitude && ![longitude isKindOfClass:[NSNull class]]) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        if (location) {
            __weak typeof (self) selfie = self;
            [[LocationManager sharedManager] nameForLocation:location completionHandler:^(NSString *placemark, NSError *error) {
                if (placemark && !error) {
                    NSMutableArray *cameraDataSectionRowsCopy = [selfie.cameraDataSectionRows mutableCopy];
                    [cameraDataSectionRowsCopy addObject:@[NSLocalizedString(@"Location Name", nil), placemark]];
                    selfie.cameraDataSectionRows = cameraDataSectionRowsCopy;
                    [selfie.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selfie.cameraDataSectionRows.count-2 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                }
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.cameraDataSectionRows.count;
    }
    return self.photo.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    if (indexPath.section == 0) {
        [self configureCameraDataCell:cell forIndexPath:indexPath];
    } else {
        NSString *tag = self.photo.tags[indexPath.row];
        [cell.textLabel setText:tag];
        [cell.textLabel setFont:[UIFont systemFontOfSize:PHOTO_INFO_FONT_SIZE]];
    }
    
    return cell;
}

- (void)configureCameraDataCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSArray *cameraDataRow = self.cameraDataSectionRows[indexPath.row];
    NSString *key = cameraDataRow[1];
    id value;
    if (key && [self.photo respondsToSelector:NSSelectorFromString(key)]) {
        value = [self.photo valueForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [NSString stringWithFormat:@"%d", [value integerValue]];
        }
    } else {
        value = key;
    }
    
    cell.textLabel.attributedText = [self attributedStringForCameraData:cameraDataRow[0] value:value];
}

- (NSAttributedString *)attributedStringForCameraData:(NSString *)cameraData value:(NSString *)value {
    if (!value) value = NSLocalizedString(@"Not available", nil);
    NSString *cameraDataString = [NSString stringWithFormat:@"%@ %@", cameraData, value];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:cameraDataString];
    [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:PHOTO_INFO_FONT_SIZE] range:[cameraDataString rangeOfString:cameraData]];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:PHOTO_INFO_FONT_SIZE] range:[cameraDataString rangeOfString:value]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[cameraDataString rangeOfString:cameraData]];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[cameraDataString rangeOfString:value]];
    return attr;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat distance = self.tableView.contentInset.top+scrollView.contentOffset.y;
    if (distance < 0) {
        CGFloat progress = MIN((-distance)/(float)PHOTO_INFO_CLOSE_OFFSET, 1);
        if (!isClosing) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoInfoViewController:didDragToClose:)]) {
                [self.delegate photoInfoViewController:self didDragToClose:progress];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat distance = self.tableView.contentInset.top+scrollView.contentOffset.y;
    CGFloat progress = MIN((-distance)/(float)PHOTO_INFO_CLOSE_OFFSET, 1);
    if (progress == 1) {
        isClosing = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoInfoViewControllerDidClose:)]) {
            [self.delegate photoInfoViewControllerDidClose:self];
        }
    }
}

@end
