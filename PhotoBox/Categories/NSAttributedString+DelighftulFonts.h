//
//  NSAttributedString+DelighftulFonts.h
//  Delightful
//
//  Created by  on 10/3/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const dlf_icon_image;
extern NSString * const dlf_icon_images;
extern NSString * const dlf_icon_camera;
extern NSString * const dlf_icon_tags;
extern NSString * const dlf_icon_envelope;
extern NSString * const dlf_icon_pushpin;
extern NSString * const dlf_icon_location;
extern NSString * const dlf_icon_location2;
extern NSString * const dlf_icon_compass;
extern NSString * const dlf_icon_clock;
extern NSString * const dlf_icon_clock2;
extern NSString * const dlf_icon_calendar;
extern NSString * const dlf_icon_bubble;
extern NSString * const dlf_icon_bubble2;
extern NSString * const dlf_icon_spinner;
extern NSString * const dlf_icon_search;
extern NSString * const dlf_icon_cog;
extern NSString * const dlf_icon_cog2;
extern NSString * const dlf_icon_bug;
extern NSString * const dlf_icon_remove;
extern NSString * const dlf_icon_switch;
extern NSString * const dlf_icon_numbered_list;
extern NSString * const dlf_icon_menu;
extern NSString * const dlf_icon_cloud_download;
extern NSString * const dlf_icon_cloud_upload;
extern NSString * const dlf_icon_download;
extern NSString * const dlf_icon_upload;
extern NSString * const dlf_icon_link;
extern NSString * const dlf_icon_star;
extern NSString * const dlf_icon_heart;
extern NSString * const dlf_icon_heart2;
extern NSString * const dlf_icon_info;
extern NSString * const dlf_icon_info2;
extern NSString * const dlf_icon_close;
extern NSString * const dlf_icon_checkmark;
extern NSString * const dlf_icon_checkmark2;
extern NSString * const dlf_icon_pause;
extern NSString * const dlf_icon_arrow_up;
extern NSString * const dlf_icon_arrow_right;
extern NSString * const dlf_icon_arrow_down;
extern NSString * const dlf_icon_arrow_left;
extern NSString * const dlf_icon_arrow_up2;
extern NSString * const dlf_icon_arrow_right2;
extern NSString * const dlf_icon_arrow_down2;
extern NSString * const dlf_icon_arrow_left2;
extern NSString * const dlf_icon_checkbox_checked;
extern NSString * const dlf_icon_mail;
extern NSString * const dlf_icon_facebook;
extern NSString * const dlf_icon_instagram;
extern NSString * const dlf_icon_twitter;
extern NSString * const dlf_icon_arrow_left3;
extern NSString * const dlf_icon_arrow_down3;
extern NSString * const dlf_icon_arrow_up3;
extern NSString * const dlf_icon_uniE635;
extern NSString * const dlf_icon_sort_numeric_desc;
extern NSString * const dlf_icon_sort_numeric_asc;
extern NSString * const dlf_icon_sort_alpha_desc;
extern NSString * const dlf_icon_sort_alpha_asc;
extern NSString * const dlf_icon_unsorted;
extern NSString * const dlf_icon_squares;
extern NSString * const dlf_icon_menu_sort;

@interface NSAttributedString (DelightfulFonts)

+ (NSAttributedString *)symbol:(NSString *)dlf_icon size:(CGFloat)size;

@end
