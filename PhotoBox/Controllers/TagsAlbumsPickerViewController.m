//
//  TagsAlbumsPickerViewController.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TagsAlbumsPickerViewController.h"
#import "TagEntryTableViewCell.h"
#import "AlbumPickerTableViewCell.h"
#import "PermissionPickerTableViewCell.h"
#import "UploadDescriptionTableViewCell.h"
#import "Album.h"
#import "Tag.h"
#import "APIClient.h"
#import "NSString+Score.h"
#import "TagsSuggestionTableViewController.h"
#import "AlbumsPickerViewController.h"
#import "DelightfulCache.h"
#import "DLFAsset.h"
#import "DLFDatabaseManager.h"
#import "SyncEngine.h"
#import "PhotoTagsCollectionViewController.h"
#import "LocationManager.h"
#import "Bolts.h"

#define LAST_SELECTED_ALBUM @"last_selected_album_key"
#define TITLE_TEXTFIELD_TAG 100000

NSString *const normalCellIdentifier = @"normalCell";

@interface TagsAlbumsPickerViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TagsSuggestionTableViewControllerPickerDelegate, AlbumsPickerViewControllerDelegate, PhotoTagsCollectionViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, assign) BOOL isFetchingTags;
@property (nonatomic, strong) Album *selectedAlbum;
@property (nonatomic, strong) TagsSuggestionTableViewController *tagsSuggestionViewController;
@property (nonatomic, assign) CGSize keyboardSize;
@property (nonatomic, strong) NSString *currentEditedTag;
@property (nonatomic, assign) NSRange currentEditedTagRange;
@property (nonatomic, strong) NSString *selectedTags;
@property (nonatomic, assign) BOOL privatePhotos;
@property (nonatomic, assign) BOOL isPreparingSmartTags;
@property (nonatomic, assign) BOOL resizeAfterUploads;
@property (nonatomic, strong) NSString *uploadTitle;
@property (nonatomic, strong) NSString *uploadDescription;

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
    self.resizeAfterUploads = [[NSUserDefaults standardUserDefaults] boolForKey:DLF_RESIZE_AFTER_UPLOAD_USER_DEFAULT_KEY];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishFetchingTagsNotification:) name:SyncEngineDidFinishFetchingNotification object:nil];
    
    [self.tableView registerClass:[TagEntryTableViewCell class] forCellReuseIdentifier:[TagEntryTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[AlbumPickerTableViewCell class] forCellReuseIdentifier:[AlbumPickerTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[PermissionPickerTableViewCell class] forCellReuseIdentifier:[PermissionPickerTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[UploadDescriptionTableViewCell class] forCellReuseIdentifier:[UploadDescriptionTableViewCell defaultCellReuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:normalCellIdentifier];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Upload", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    __weak typeof (self) selfie = self;
    [[DLFDatabaseManager manager] tagsWithCompletion:^(NSArray *tags) {
        selfie.tags = tags;
    }];
    
    [[SyncEngine sharedEngine] startSyncingTags];
    
    [[self prepareSmartTags] continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            selfie.isPreparingSmartTags = NO;
            [selfie.tableView reloadData];
        });
        return nil;
    }];
}

- (BFTask *)prepareSmartTags {
    self.isPreparingSmartTags = YES;
    BFTaskCompletionSource *preparingSmartTagsTask = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BFTask *smartTagsTask = [BFTask taskWithResult:nil];
        for (DLFAsset *asset in self.selectedAssets) {
            smartTagsTask = [smartTagsTask continueWithBlock:^id(BFTask *task) {
                BFTaskCompletionSource *imageFetchTask = [BFTaskCompletionSource taskCompletionSource];
                PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
                editOptions.networkAccessAllowed = YES;
                PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                [option setVersion:PHImageRequestOptionsVersionOriginal];
                [[PHImageManager defaultManager] requestImageDataForAsset:asset.asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        CIImage *image = [CIImage imageWithData:imageData];
                        [imageFetchTask setResult:image];
                    });
                }];
                
                return [imageFetchTask.task continueWithBlock:^id(BFTask *task) {
                    CIImage *image = task.result;
                    return [[asset prepareSmartTagsWithCIImage:image] continueWithBlock:^id(BFTask *task) {
                        NSArray *tags = task.result;
                        asset.smartTags = tags;
                        return nil;
                    }];
                }];
            }];
        }
        [smartTagsTask continueWithBlock:^id(BFTask *task) {
            [preparingSmartTagsTask setResult:task.result];
            return [BFTask taskWithResult:nil];
        }];
    });
    
    return preparingSmartTagsTask.task;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SyncEngineDidFinishFetchingNotification object:nil];
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
    return (section==TagsAlbumsPickerCollectionViewSectionsTags)?TagsSectionRowsCount:((section==TagsAlbumsPickerCollectionViewSectionsTitle)?TitleSectionRowsCount:1);
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsAlbums) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AlbumsPickerViewController *albumsPicker = [storyBoard instantiateViewControllerWithIdentifier:@"albumsPicker"];
        [albumsPicker setDelegate:self];
        [albumsPicker setSelectedAlbum:self.selectedAlbum];
        [self.navigationController pushViewController:albumsPicker animated:YES];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsTags && indexPath.row == TagsSectionRowsSmartTags && !self.isPreparingSmartTags) {
        PhotoTagsCollectionViewController *tagsVC = [[PhotoTagsCollectionViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        [tagsVC setAssets:self.selectedAssets];
        [tagsVC setDelegate:self];
        [self.navigationController pushViewController:tagsVC animated:YES];
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
        if (indexPath.row == TagsSectionRowsSmartTags) {
            [cell.textLabel setText:(self.isPreparingSmartTags)?NSLocalizedString(@"Preparing smart tags ...", nil):NSLocalizedString(@"Smart Tags", nil)];
            [cell.textLabel setTextColor:(self.isPreparingSmartTags)?[UIColor grayColor]:[UIColor blackColor]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        } else {
            [((TagEntryTableViewCell *)cell).tagField setDelegate:self];
        }
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsPermission) {
        [((PermissionPickerTableViewCell *)cell).permissionSwitch setOn:self.privatePhotos];
        [((PermissionPickerTableViewCell *)cell).permissionSwitch addTarget:self action:@selector(permissionSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsResizeAfterUpload) {
        [((PermissionPickerTableViewCell *)cell).permissionSwitch setOn:self.resizeAfterUploads];
        [((PermissionPickerTableViewCell *)cell).permissionSwitch addTarget:self action:@selector(resizeAfterUploadSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
        [((PermissionPickerTableViewCell *)cell).permissionLabel setText:NSLocalizedString(@"Resize Uploaded Photos", nil)];
    }
    
    if (indexPath.section == TagsAlbumsPickerCollectionViewSectionsTitle) {
        if (indexPath.row == TitleSectionRowsTitle) {
            ((TagEntryTableViewCell *)cell).tagField.placeholder = NSLocalizedString(@"Title (Optional)", nil);
            [((TagEntryTableViewCell *)cell).tagField setTag:TITLE_TEXTFIELD_TAG];
            [((TagEntryTableViewCell *)cell).tagField setDelegate:self];
            if (self.uploadTitle && self.uploadTitle.length > 0) {
                ((TagEntryTableViewCell *)cell).tagField.text = self.uploadTitle;
            }
        } else if (indexPath.row == TitleSectionRowsDescription) {
            [((UploadDescriptionTableViewCell *)cell).textView setDelegate:self];
            if (self.uploadDescription && self.uploadDescription.length > 0) {
                ((UploadDescriptionTableViewCell *)cell).textView.text = self.uploadDescription;
            }
        }
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
        case TagsAlbumsPickerCollectionViewSectionsResizeAfterUpload:
            return NSLocalizedString(@"Free up space", nil);
        default:
            break;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == TagsAlbumsPickerCollectionViewSectionsResizeAfterUpload) {
        return NSLocalizedString(@"If you turn this on, Delightful will delete the uploaded photos and replace them with smaller size photos to free up storage space from your device. You will need to allow Delightful to delete the uploaded photos. The deleted photos will stay in Recently Deleted album until you permanently delete them.", nil);
    }
    return nil;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section==TagsAlbumsPickerCollectionViewSectionsTags&&indexPath.row==TagsSectionRowsSmartTags)?normalCellIdentifier:[(id)[self cellClassForIndexPath:indexPath] defaultCellReuseIdentifier];
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TagsAlbumsPickerCollectionViewSectionsTags:
            if (indexPath.row == TagsSectionRowsSmartTags) {
                return [UITableViewCell class];
            }
            return [TagEntryTableViewCell class];
            break;
        case TagsAlbumsPickerCollectionViewSectionsAlbums:
            return [AlbumPickerTableViewCell class];
            break;
        case TagsAlbumsPickerCollectionViewSectionsPermission:
        case TagsAlbumsPickerCollectionViewSectionsResizeAfterUpload:
            return [PermissionPickerTableViewCell class];
        case TagsAlbumsPickerCollectionViewSectionsTitle:
            if (indexPath.row == TitleSectionRowsTitle) {
                return [TagEntryTableViewCell class];
            } else {
                return [UploadDescriptionTableViewCell class];
            }
            
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text;
    NSString *newText = [text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag != TITLE_TEXTFIELD_TAG) {
        self.selectedTags = newText;
        
        NSString *tagToSuggest = [self tagToSuggestForText:newText replacementRange:range replacementString:string];
        self.currentEditedTag = tagToSuggest;
        if (self.tags) {
            if (tagToSuggest && tagToSuggest.length > 0) {
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
                    NSString *tagName = evaluatedObject;
                    return [[tagName lowercaseString] scoreAgainst:[tagToSuggest lowercaseString]] > 0.5;
                }];
                NSArray *suggestions = [self.tags filteredArrayUsingPredicate:predicate];
                [self showSuggestions:suggestions];
            } else {
                [self showSuggestions:nil];
            }
        }
    } else {
        self.uploadTitle = text;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == TITLE_TEXTFIELD_TAG) {
        self.uploadTitle = textField.text;
    }
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
    //CLS_LOG(@"Suggestions: %@", [[suggestions valueForKeyPath:@"tagId"] componentsJoinedByString:@","]);
    if (suggestions && suggestions.count > 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:TagsAlbumsPickerCollectionViewSectionsTags]];
        CGRect cellFrameInTableViewSuperview = [self.tableView.superview convertRect:cell.frame fromView:self.tableView];
        
        if (!self.tagsSuggestionViewController) {
            self.tagsSuggestionViewController = [[TagsSuggestionTableViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.tagsSuggestionViewController setPickerDelegate:self];
        }
        [self.tagsSuggestionViewController setSuggestions:suggestions];
        
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

#pragma mark - Tags Fetching Notification

- (void)didFinishFetchingTagsNotification:(NSNotification *)notification {
    if ([notification.userInfo[SyncEngineNotificationResourceKey] isEqualToString:NSStringFromClass([Tag class])]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SyncEngineDidFinishFetchingNotification object:nil];
        __weak typeof (self) selfie = self;
        [[DLFDatabaseManager manager] tagsWithCompletion:^(NSArray *tags) {
            selfie.tags = tags;
        }];
    }
    
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

- (void)albumsPickerViewController:(AlbumsPickerViewController *)albumsPicker didSelectAlbum:(Album *)album {
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

- (void)resizeAfterUploadSwitchDidChange:(UISwitch *)sender {
    self.resizeAfterUploads = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:self.resizeAfterUploads forKey:DLF_RESIZE_AFTER_UPLOAD_USER_DEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doneButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsAlbumsPickerViewController:didFinishSelectTagsAndAlbum:)]) {
        for (DLFAsset *asset in self.selectedAssets) {
            [asset setTags:self.selectedTags];
            [asset setAlbum:self.selectedAlbum];
            [asset setPrivatePhoto:self.privatePhotos];
            [asset setScaleAfterUpload:self.resizeAfterUploads];
            NSString *trimmedTitle = [self.uploadTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *trimmedDescription = [self.uploadDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [asset setPhotoTitle:trimmedTitle.length>0?trimmedTitle:nil];
            [asset setPhotoDescription:trimmedDescription.length>0?trimmedDescription:nil];
        }
        [self.delegate tagsAlbumsPickerViewController:self didFinishSelectTagsAndAlbum:self.selectedAssets];
    }
}

#pragma mark - <PhotoTagsCollectionViewControllerDelegate>

- (void)photoTagsViewController:(PhotoTagsCollectionViewController *)controller didChangeSmartTagsForAsset:(DLFAsset *)asset {
    NSString *format = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(asset)), NSStringFromSelector(@selector(localIdentifier))];
    DLFAsset *changedAsset = [[self.selectedAssets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", format, asset.asset.localIdentifier]] firstObject];
    [changedAsset setSmartTags:asset.smartTags];
    
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.uploadDescription = textView.text;
}


@end
