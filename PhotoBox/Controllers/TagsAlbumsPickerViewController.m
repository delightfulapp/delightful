//
//  TagsAlbumsPickerViewController.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "TagsAlbumsPickerViewController.h"

#import "TagEntryTableViewCell.h"

#import "AlbumPickerTableViewCell.h"

#import "PermissionPickerTableViewCell.h"

#import "Album.h"

#import "Tag.h"

#import "PhotoBoxClient.h"

#import "NSString+Score.h"

@interface TagsAlbumsPickerViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, assign) BOOL isFetchingTags;

@property (nonatomic, strong) Album *selectedAlbum;

@end

@implementation TagsAlbumsPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TagEntryTableViewCell class] forCellReuseIdentifier:[TagEntryTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[AlbumPickerTableViewCell class] forCellReuseIdentifier:[AlbumPickerTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[PermissionPickerTableViewCell class] forCellReuseIdentifier:[PermissionPickerTableViewCell defaultCellReuseIdentifier]];
    
    [self fetchTags];
}

- (void)fetchTags {
    if (!self.isFetchingTags) {
        self.isFetchingTags = YES;
        
        [[PhotoBoxClient sharedClient] getResource:TagResource action:ListAction resourceId:nil page:0 success:^(NSArray *results) {
            self.isFetchingTags = NO;
            if (results && [results isKindOfClass:[NSArray class]] ) {
                self.tags = results;
            }
        } failure:^(NSError *error) {
            self.isFetchingTags = NO;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView endEditing:YES];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return TagsAlbumsPickerCollectionViewSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForIndexPath:indexPath]];
    [cell setAccessoryView:nil];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsAlbums) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsTags) {
        [((TagEntryTableViewCell *)cell).tagField setDelegate:self];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[[self cellClassForIndexPath:indexPath] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TagsAlbumsPickerCollectionViewSectionsTags:
            return NSLocalizedString(@"Tags", nil);
            break;
        case TagsAlbumsPickerCollectionViewSectionsPermission:
            return NSLocalizedString(@"Permission", nil);
        default:
            break;
    }
    return nil;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return [(id)[self cellClassForIndexPath:indexPath] defaultCellReuseIdentifier];
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TagsAlbumsPickerCollectionViewSectionsTags:
            return [TagEntryTableViewCell class];
            break;
        case TagsAlbumsPickerCollectionViewSectionsAlbums:
            return [AlbumPickerTableViewCell class];
            break;
        case TagsAlbumsPickerCollectionViewSectionsPermission:
            return [PermissionPickerTableViewCell class];
        default:
            break;
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text;
    NSString *newText = [text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *substringAfterCurrentRange = [newText substringFromIndex:range.location];
    NSString *substringBeforeCurrentRange = [newText substringToIndex:range.location];
    
    NSRange commaAfter = [substringAfterCurrentRange rangeOfString:@","];
    NSRange commaBefore = [substringBeforeCurrentRange rangeOfString:@"," options:NSBackwardsSearch];
    
    NSInteger startIndex = (commaBefore.location!=NSNotFound)?commaBefore.location:([string isEqualToString:@","]?range.location:0);
    NSInteger endIndex = (commaAfter.location!=NSNotFound)?commaAfter.location+range.location:newText.length-1;
    NSInteger length = endIndex-startIndex+1;
    
    NSString *tagToSuggest = (length>0)?[newText substringWithRange:NSMakeRange(startIndex, length)]:nil;
    if (tagToSuggest) {
        tagToSuggest = [tagToSuggest stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
    }
    
    if (self.tags) {
        if (tagToSuggest && tagToSuggest.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Tag *evaluatedObject, NSDictionary *bindings) {
                NSString *tagName = evaluatedObject.tagId;
                return [[tagName lowercaseString] scoreAgainst:[tagToSuggest lowercaseString]] > 0.5;
            }];
            NSArray *suggestions = [self.tags filteredArrayUsingPredicate:predicate];
            
        }
    } else {
        [self fetchTags];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
