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

#import "DelightfulCache.h"

#import "DLFAsset.h"

#define LAST_SELECTED_ALBUM @"last_selected_album_key"

@interface TagsAlbumsPickerViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TagsSuggestionTableViewControllerPickerDelegate, AlbumsPickerTableViewControllerPickerDelegate>

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, assign) BOOL isFetchingTags;

@property (nonatomic, strong) Album *selectedAlbum;

@property (nonatomic, strong) TagsSuggestionTableViewController *tagsSuggestionViewController;

@property (nonatomic, assign) CGSize keyboardSize;

@property (nonatomic, strong) NSString *currentEditedTag;

@property (nonatomic, assign) NSRange currentEditedTagRange;

@property (nonatomic, strong) NSString *selectedTags;

@property (nonatomic, assign) BOOL privatePhotos;

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
    
    self.privatePhotos = YES;
    
    if ([[DelightfulCache sharedCache] objectForKey:LAST_SELECTED_ALBUM]) self.selectedAlbum = [NSKeyedUnarchiver unarchiveObjectWithData:[[DelightfulCache sharedCache] objectForKey:LAST_SELECTED_ALBUM]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self.tableView registerClass:[TagEntryTableViewCell class] forCellReuseIdentifier:[TagEntryTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[AlbumPickerTableViewCell class] forCellReuseIdentifier:[AlbumPickerTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[PermissionPickerTableViewCell class] forCellReuseIdentifier:[PermissionPickerTableViewCell defaultCellReuseIdentifier]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Upload", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
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
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsAlbums) {
        AlbumsPickerTableViewController *albumsPicker = [[AlbumsPickerTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [albumsPicker setDelegate:self];
        [albumsPicker setSelectedAlbum:self.selectedAlbum];
        [self.navigationController pushViewController:albumsPicker animated:YES];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForIndexPath:indexPath]];
    [cell setAccessoryView:nil];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsAlbums) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        if (self.selectedAlbum) ((AlbumPickerTableViewCell *)cell).selectedAlbumLabel.text = self.selectedAlbum.name;
        else [((AlbumPickerTableViewCell *)cell) setNoSelectedAlbum];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsTags) {
        [((TagEntryTableViewCell *)cell).tagField setDelegate:self];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsPermission) {
        [((PermissionPickerTableViewCell *)cell).permissionSwitch setOn:self.privatePhotos];
        [((PermissionPickerTableViewCell *)cell).permissionSwitch addTarget:self action:@selector(permissionSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
        
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
    
    self.selectedTags = newText;
    
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
        NSString *text = [cell.tagField.text stringByReplacingCharactersInRange:self.currentEditedTagRange withString:tag];
        NSArray *tagsArray = [text componentsSeparatedByString:@","];
        NSMutableArray *trimmedTagsArray = [NSMutableArray arrayWithCapacity:tagsArray.count];
        [tagsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            [trimmedTagsArray addObject:[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }];
        NSString *newTags = [[trimmedTagsArray componentsJoinedByString:@", "] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
        if (cell) {
            cell.tagField.text = [newTags stringByAppendingString:@", "];
            
        }
        self.selectedTags = newTags;
    }
    
    [self.tagsSuggestionViewController.tableView removeFromSuperview];
}

#pragma mark - AlbumsPickerTableViewControllerPickerDelegate

- (void)albumsPickerViewController:(AlbumsPickerTableViewController *)albumsPicker didSelectAlbum:(Album *)album {
    self.selectedAlbum = album;
    
    if (self.selectedAlbum) [[DelightfulCache sharedCache] setObject:[NSKeyedArchiver archivedDataWithRootObject:album] forKey:LAST_SELECTED_ALBUM];
    else [[DelightfulCache sharedCache] setObject:nil forKey:LAST_SELECTED_ALBUM];
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Buttons

- (void)permissionSwitchDidChange:(UISwitch *)sender {
    self.privatePhotos = sender.isOn;
}

- (void)doneButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsAlbumsPickerViewController:didFinishSelectTagsAndAlbum:)]) {
        for (DLFAsset *asset in self.selectedAssets) {
            [asset setTags:self.selectedTags];
            [asset setAlbum:self.selectedAlbum];
            [asset setPrivatePhoto:self.privatePhotos];
        }
        [self.delegate tagsAlbumsPickerViewController:self didFinishSelectTagsAndAlbum:self.selectedAssets];
    }
}

@end
