//
//  SettingsTableViewController.m
//  Delightful
//
//  Created by Nico Prananta on 5/12/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "ConnectionManager.h"

#import <MessageUI/MessageUI.h>

#import "HintsViewController.h"

@interface SettingsTableViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *items;

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
                   @[@{@"title": NSLocalizedString(@"Delightful Version", nil), @"detail": appVersion},
                     @{@"title": NSLocalizedString(@"Delightful on Twitter", nil), @"detail": @"@delightfulapp"},
                     @{@"title": NSLocalizedString(@"Created by Nico", nil), @"detail": @"@nicnocquee"},
                     @{@"title": NSLocalizedString(@"Found a bug?", nil), @"detail": @"", @"title_is_link": @(YES)}],
                   @[@{@"title": NSLocalizedString(@"Gestures", nil), @"detail": @"", @"title_is_link": @(YES)}]
                   ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSDictionary *dictionary = ((NSArray *)self.items[indexPath.section])[indexPath.row];
    [cell.textLabel setText:dictionary[@"title"]];
    [cell.detailTextLabel setText:dictionary[@"detail"]];
    
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
    } else if (indexPath.section == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://trovebox.com"]];
    } else if (indexPath.section == 2) {
        HintsViewController *hints = [[HintsViewController alloc] init];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:hints];
        [self presentViewController:navCon animated:YES completion:nil];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/delightfulapp"]];
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/nicnocquee"]];
        } else if (indexPath.row == 3) {
            NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
            NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
            
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            [mail setSubject:[NSString stringWithFormat:@"Bug report %@", appVersion]];
            [mail setToRecipients:@[@"officialdelightfulapp@gmail.com"]];
            [mail setMessageBody:@"Please provide detail description of the bug and how to reproduce it." isHTML:NO];
            [mail setMailComposeDelegate:self];
            [self presentViewController:mail animated:YES completion:nil];
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to logout?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[ConnectionManager sharedManager] logout];
        }];
    }
}

#pragma mark - Mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
