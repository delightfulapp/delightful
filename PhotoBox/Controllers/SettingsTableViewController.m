//
//  SettingsTableViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "ConnectionManager.h"

#import <MessageUI/MessageUI.h>

#import "HintsViewController.h"

#import "NPRImageDownloader.h"

#import "DLFImageUploader.h"

#import "OriginalImageDownloaderViewController.h"

#import "UploadViewController.h"

static void * imageDownloadContext = &imageDownloadContext;

@interface SettingsTableViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) int numberOfDownloads;
@property (nonatomic, assign) int numberOfUploads;
@property (nonatomic, assign) int numberOfFailUploads;

@end

@implementation SettingsTableViewController

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
    
    self.title = NSLocalizedString(@"Settings", nil);
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
    self.items = @[
                   @[@{@"title": NSLocalizedString(@"Logout", nil), @"detail": @"", @"title_is_link": @(YES)}],
                   @[@{@"title": NSLocalizedString(@"Downloads", nil), @"detail": @""},
                     @{@"title": NSLocalizedString(@"Uploads", nil), @"detail": @""}],
                   @[@{@"title": NSLocalizedString(@"Delightful Version", nil), @"detail": appVersion},
                     @{@"title": NSLocalizedString(@"Delightful on Twitter", nil), @"detail": @"@delightfulapp"},
                     @{@"title": NSLocalizedString(@"Created by Nico", nil), @"detail": @"@nicnocquee"},
                     @{@"title": NSLocalizedString(@"Open Source", nil), @"detail": @""},
                     @{@"title": NSLocalizedString(@"Credits", nil), @"detail": @""},
                     @{@"title": NSLocalizedString(@"Found a bug?", nil), @"detail": @""}],
                   @[@{@"title": NSLocalizedString(@"Gestures", nil), @"detail": @""}]
                   ];
    
    self.numberOfDownloads = (int)[[NPRImageDownloader sharedDownloader] numberOfDownloads];
    
    [[NPRImageDownloader sharedDownloader] addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfDownloads)) options:0 context:imageDownloadContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadNumberChangeNotification:) name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.numberOfUploads = (int)[[DLFImageUploader sharedUploader] numberOfUploading];
    self.numberOfDownloads = (int)[[NPRImageDownloader sharedDownloader] numberOfDownloads];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DLFAssetUploadDidChangeNumberOfUploadsNotification object:nil];
    [[NPRImageDownloader sharedDownloader] removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfDownloads)) context:imageDownloadContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)self.items[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    NSDictionary *dictionary = ((NSArray *)self.items[indexPath.section])[indexPath.row];
    NSString *titleText = dictionary[@"title"];
    NSString *detailText = dictionary[@"detail"];
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                if (self.numberOfDownloads > 0) {
                    titleText = (self.numberOfDownloads==1)?[NSString stringWithFormat:NSLocalizedString(@"Downloading %d photo ...", nil), self.numberOfDownloads]:[NSString stringWithFormat:NSLocalizedString(@"Downloading %d photos ...", nil), self.numberOfDownloads];
                    detailText = @"";
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                break;
            } case 1:{
                if (self.numberOfUploads > 0) {
                    titleText = (self.numberOfUploads==1)?[NSString stringWithFormat:NSLocalizedString(@"Uploading %d photo ...", nil), self.numberOfUploads]:[NSString stringWithFormat:NSLocalizedString(@"Uploading %d photos ...", nil), self.numberOfUploads];
                    detailText = @"";
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                } else if (self.numberOfFailUploads > 0) {
                    titleText = (self.numberOfFailUploads==1)?[NSString stringWithFormat:NSLocalizedString(@"Uploading %d photo failed", nil), self.numberOfFailUploads]:[NSString stringWithFormat:NSLocalizedString(@"Uploading %d photos failed", nil), self.numberOfFailUploads];
                    detailText = @"";
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                break;
            }
            default:
                break;
        }
    }
    
    [cell.textLabel setText:titleText];
    [cell.detailTextLabel setText:detailText];
    
    if ([dictionary objectForKey:@"title_is_link"] && [[dictionary objectForKey:@"title_is_link"] boolValue]) {
        [cell.textLabel setTextColor:self.view.tintColor];
    } else {
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self logoutTapped];
    } else if (indexPath.section == 4) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://trovebox.com"]];
    } else if (indexPath.section == 3) {
        HintsViewController *hints = [[HintsViewController alloc] init];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:hints];
        [self presentViewController:navCon animated:YES completion:nil];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/delightfulapp/delightful/blob/master/WhatsNew.md"]];
        } else if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/delightfulapp"]];
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/nicnocquee"]];
        } else if (indexPath.row == 3) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/delightfulapp/delightful"]];
        } else if (indexPath.row == 4) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/delightfulapp/delightful/blob/master/Credits.md"]];
        } else if (indexPath.row == 5) {
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
            NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
            
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            [mail setSubject:[NSString stringWithFormat:@"Bug report %@", appVersion]];
            [mail setToRecipients:@[@"nico@delightfuldev.com"]];
            [mail setMessageBody:@"Please provide detail description of the bug and how to reproduce it." isHTML:NO];
            [mail setMailComposeDelegate:self];
            [self presentViewController:mail animated:YES completion:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            OriginalImageDownloaderViewController *downloadingVC = [[OriginalImageDownloaderViewController alloc] initWithStyle:UITableViewStylePlain];
            [self showViewController:downloadingVC sender:nil];
        } else if (indexPath.row == 1) {
            UploadViewController *uploadVC = [[UploadViewController alloc] init];
            [self showViewController:uploadVC sender:nil];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[[ConnectionManager sharedManager] baseURL] absoluteString];
    }
    return nil;
}

#pragma mark - Buttons

- (void)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)logoutTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure you want to logout?", nil) message:nil preferredStyle:(IS_IPAD)?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ConnectionManager sharedManager] logout];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    if (IS_IPAD) {
        [alert addAction:cancelAction];
        [alert addAction:action];
    } else {
        [alert addAction:action];
        [alert addAction:cancelAction];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfDownloads))] && context == imageDownloadContext) {
        self.numberOfDownloads = (int)[[NPRImageDownloader sharedDownloader] numberOfDownloads];
        [self.tableView reloadData];
    }
}

#pragma mark - Notification

- (void)uploadNumberChangeNotification:(NSNotification *)notification {
    self.numberOfUploads = [notification.userInfo[kNumberOfUploadsKey] intValue];
    self.numberOfFailUploads = [notification.userInfo[kNumberOfFailUploadsKey] intValue];
    [self.tableView reloadData];
}

@end
