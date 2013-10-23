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

#define PHOTOBOX_TESTFLIGHT_BETA_URL @"http://tflig.ht/1c3y5YF"
#define PHOTOBOX_SHARE_TEXT @"Photobox, Trovebox client for iPhone, is looking for beta users. Get your invite here."
#define PHOTOBOX_SHARE_TWEET @"Photobox, @trovebox client for iPhone, is looking for beta users. Get your invite here. via @nicnocquee"
#define PHOTOBOX_SHARE_SUBJECT @"Checkout PhotoBox, Trovebox client for iPhone"

extern NSString *PBX_allAlbumIdentifier;

#define PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO @"photobox.PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO"

#define PBX_LOG(__FORMAT__, ...) CLS_LOG(@"[%@]$ " __FORMAT__, NSStringFromClass([self class]), ##__VA_ARGS__)

#endif
