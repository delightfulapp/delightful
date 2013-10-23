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

extern NSString *PBX_allAlbumIdentifier;

#define PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO @"photobox.PBX_DID_SHOW_SCROLL_UP_AND_DOWN_TO_CLOSE_FULL_SCREEN_PHOTO"

#define PBX_LOG(__FORMAT__, ...) CLS_LOG(@"[%@]$ " __FORMAT__, NSStringFromClass([self class]), ##__VA_ARGS__)

#endif
