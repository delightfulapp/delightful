//
//  Constants.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#ifndef PhotoBox_Constants_h
#define PhotoBox_Constants_h

#define ARRAY_SEPARATOR @"\t"
#define PHOTO_SPACING 20

#define APP_VERSION_KEY @"delightful.appversion"

#define PHOTOBOX_TESTFLIGHT_BETA_URL @"http://tflig.ht/1c3y5YF"
#define PHOTOBOX_SHARE_TEXT @"Photobox, Trovebox client for iPhone, is looking for beta users. Get your invite here."
#define PHOTOBOX_SHARE_TWEET @"Photobox, @trovebox client for iPhone, is looking for beta users. Get your invite here. via @nicnocquee"
#define PHOTOBOX_SHARE_SUBJECT @"Checkout PhotoBox, Trovebox client for iPhone"

extern NSString *PBX_allAlbumIdentifier;
extern NSString *PBX_downloadHistoryIdentifier;
extern NSString *PBX_favoritesAlbumIdentifier;

#define DLF_DID_SHOW_PINCH_GESTURE_TIP @"delightful.DLF_DID_SHOW_PINCH_GESTURE_TIP"
#define PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO @"photobox.PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO"
#define PBX_SHOWN_INTRO_VIEW_USER_DEFAULT_KEY @"photobox.PBX_SHOWN_INTRO_VIEW_USER_DEFAULT_KEY"
#define DLF_UPLOADED_ASSETS @"delightful.UPLOADED_ASSETS"
#define DLF_RESIZE_AFTER_UPLOAD_USER_DEFAULT_KEY @"delightful.DLF_RESIZE_AFTER_UPLOAD_USER_DEFAULT_KEY"

#if !defined DEBUG && __has_include("Crashlytics/Crashlytics.h")
#define PBX_LOG(__FORMAT__, ...) CLS_LOG(@"[%@]$ " __FORMAT__, NSStringFromClass([self class]), ##__VA_ARGS__)
#else
#define PBX_LOG(__FORMAT__, ...) CLS_LOG(@"[%@]$ " __FORMAT__, NSStringFromClass([self class]), ##__VA_ARGS__)
#endif

#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#endif
