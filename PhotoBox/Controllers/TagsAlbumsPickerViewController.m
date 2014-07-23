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

#import "TagsSuggestionTableViewController.h"

#import "AlbumsPickerTableViewController.h"

@interface TagsAlbumsPickerViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TagsSuggestionTableViewControllerPickerDelegate, AlbumsPickerTableViewControllerPickerDelegate>

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, assign) BOOL isFetchingTags;

@property (nonatomic, strong) Album *selectedAlbum;

@property (nonatomic, strong) TagsSuggestionTableViewController *tagsSuggestionViewController;

@property (nonatomic, assign) CGSize keyboardSize;

@property (nonatomic, strong) NSString *currentEditedTag;

@property (nonatomic, assign) NSRange currentEditedTagRange;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
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
    if (self.tagsSuggestionViewController.tableView.superview) [self.tagsSuggestionViewController.tableView removeFromSuperview];
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
    
    AlbumsPickerTableViewController *albumsPicker = [[AlbumsPickerTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [albumsPicker setDelegate:self];
    [self.navigationController pushViewController:albumsPicker animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForIndexPath:indexPath]];
    [cell setAccessoryView:nil];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsAlbums) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
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
    NSString *tagToSuggest = [self tagToSuggestForText:newText replacementRange:range replacementString:string];
    self.currentEditedTag = tagToSuggest;
    if (self.tags) {
        if (tagToSuggest && tagToSuggest.length > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Tag *evaluatedObject, NSDictionary *bindings) {
                NSString *tagName = evaluatedObject.tagId;
                return [[tagName lowercaseString] scoreAgainst:[tagToSuggest lowercaseString]] > 0.5;
            }];
            NSArray *suggestions = [self.tags filteredArrayUsingPredicate:predicate];
            [self showSuggestions:suggestions];
        } else {
            [self showSuggestions:nil];
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

- (NSString *)tagToSuggestForText:(NSString *)newText replacementRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@","]) {
        return nil;
    }
    
    NSString *substringAfterCurrentRange = [newText substringFromIndex:range.location];
    NSString *substringBeforeCurrentRange = [newText substringToIndex:range.location];
    
    NSRange commaAfter = [substringAfterCurrentRange rangeOfString:@","];
    NSRange commaBefore = [substringBeforeCurrentRange rangeOfString:@"," options:NSBackwardsSearch];
    
    NSInteger startIndex = (commaBefore.location!=NSNotFound)?commaBefore.location+1:([string isEqualToString:@","]?range.location+1:0);
    NSInteger endIndex = (commaAfter.location!=NSNotFound)?commaAfter.location+range.location-1:newText.length-1;
    NSInteger length = endIndex-startIndex+1;
    
    
    NSString *tagToSuggest = (length>0)?[newText substringWithRange:NSMakeRange(startIndex, length)]:nil;
    if (tagToSuggest) {
        tagToSuggest = [tagToSuggest stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
    }
    
    if (length > 0 && tagToSuggest) {
        self.currentEditedTagRange = NSMakeRange(startIndex, length);
    } else {
        self.currentEditedTagRange = NSMakeRange(NSNotFound, 0);
    }
    
    return tagToSuggest;
}

- (void)showSuggestions:(NSArray *)suggestions{
    //NSLog(@"Suggestions: %@", [[suggestions valueForKeyPath:@"tagId"] componentsJoinedByString:@","]);
    if (suggestions && suggestions.count > 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TagsAlbumsPickerCollectionViewSectionsTags]];
        CGRect cellFrameInTableViewSuperview = [self.tableView.superview convertRect:cell.frame fromView:self.tableView];
        
        if (!self.tagsSuggestionViewController) {
            self.tagsSuggestionViewController = [[TagsSuggestionTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.tagsSuggestionViewController setPickerDelegate:self];
        }
        [self.tagsSuggestionViewController setSuggestions:[suggestions valueForKeyPath:NSStringFromSelector(@selector(tagId))]];
        
        self.tagsSuggestionViewController.tableView.frame = ({
            CGRect frame = self.tagsSuggestionViewController.tableView.frame;
            frame.origin.y = cellFrameInTableViewSuperview.origin.y + cell.frame.size.height;
            frame.size.height = CGRectGetHeight(self.view.frame) - self.keyboardSize.height - frame.origin.y;
            frame;
        });
        
        [self.tagsSuggestionViewController.tableView reloadData];
        
        [self.tableView.superview addSubview:self.tagsSuggestionViewController.tableView];
        
    } else {
        [self.tagsSuggestionViewController.tableView removeFromSuperview];
    }
}

#pragma mark - Keyboard notifications

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
}

#pragma mark - TagsSuggestionTableViewControllerPickerDelegate

- (void)tagsSuggestionViewController:(TagsSuggestionTableViewController *)tagsViewController didSelectTag:(NSString *)tag {
    if (self.currentEditedTag && self.currentEditedTagRange.location != NSNotFound) {
        TagEntryTableViewCell *cell = (TagEntryTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TagsAlbumsPickerCollectionViewSectionsTags]];
        if (cell) {
            NSString *text = [cell.tagField.text stringByReplacingCharactersInRange:self.currentEditedTagRange withString:tag];
            NSArray *tagsArray = [text componentsSeparatedByString:@","];
            NSMutableArray *trimmedTagsArray = [NSMutableArray arrayWithCapacity:tagsArray.count];
            [tagsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [trimmedTagsArray addObject:[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }];
            cell.tagField.text = [trimmedTagsArray componentsJoinedByString:@", "];
        }
    }
    
    [self.tagsSuggestionViewController.tableView removeFromSuperview];
}

#pragma mark - AlbumsPickerTableViewControllerPickerDelegate

- (void)albumsPickerViewController:(AlbumsPickerTableViewController *)albumsPicker didSelectAlbum:(Album *)album {
    self.selectedAlbum = album;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
