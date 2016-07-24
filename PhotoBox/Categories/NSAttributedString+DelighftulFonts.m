//
//  NSAttributedString+DelighftulFonts.m
//  Delightful
//
//  Created by  on 10/3/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "NSAttributedString+DelighftulFonts.h"

NSString * const dlf_icon_image = @"\ue600";
NSString * const dlf_icon_images = @"\ue601";
NSString * const dlf_icon_camera = @"\ue602";
NSString * const dlf_icon_tags = @"\ue603";
NSString * const dlf_icon_envelope = @"\ue61c";
NSString * const dlf_icon_pushpin = @"\ue604";
NSString * const dlf_icon_location = @"\ue61d";
NSString * const dlf_icon_location2 = @"\ue605";
NSString * const dlf_icon_compass = @"\ue606";
NSString * const dlf_icon_clock = @"\ue607";
NSString * const dlf_icon_clock2 = @"\ue608";
NSString * const dlf_icon_calendar = @"\ue61e";
NSString * const dlf_icon_bubble = @"\ue61f";
NSString * const dlf_icon_bubble2 = @"\ue620";
NSString * const dlf_icon_spinner = @"\ue609";
NSString * const dlf_icon_search = @"\ue60a";
NSString * const dlf_icon_cog = @"\ue60b";
NSString * const dlf_icon_cog2 = @"\ue621";
NSString * const dlf_icon_bug = @"\ue60c";
NSString * const dlf_icon_remove = @"\ue60d";
NSString * const dlf_icon_switch = @"\ue60e";
NSString * const dlf_icon_numbered_list = @"\ue622";
NSString * const dlf_icon_menu = @"\ue623";
NSString * const dlf_icon_cloud_download = @"\ue60f";
NSString * const dlf_icon_cloud_upload = @"\ue610";
NSString * const dlf_icon_download = @"\ue624";
NSString * const dlf_icon_upload = @"\ue625";
NSString * const dlf_icon_link = @"\ue626";
NSString * const dlf_icon_star = @"\ue611";
NSString * const dlf_icon_heart = @"\ue612";
NSString * const dlf_icon_heart2 = @"\ue613";
NSString * const dlf_icon_info = @"\ue627";
NSString * const dlf_icon_info2 = @"\ue628";
NSString * const dlf_icon_close = @"\ue629";
NSString * const dlf_icon_checkmark = @"\ue614";
NSString * const dlf_icon_checkmark2 = @"\ue615";
NSString * const dlf_icon_pause = @"\ue616";
NSString * const dlf_icon_arrow_up = @"\ue62a";
NSString * const dlf_icon_arrow_right = @"\ue62b";
NSString * const dlf_icon_arrow_down = @"\ue62c";
NSString * const dlf_icon_arrow_left = @"\ue62d";
NSString * const dlf_icon_arrow_up2 = @"\ue62e";
NSString * const dlf_icon_arrow_right2 = @"\ue62f";
NSString * const dlf_icon_arrow_down2 = @"\ue630";
NSString * const dlf_icon_arrow_left2 = @"\ue631";
NSString * const dlf_icon_checkbox_checked = @"\ue617";
NSString * const dlf_icon_mail = @"\ue618";
NSString * const dlf_icon_facebook = @"\ue619";
NSString * const dlf_icon_instagram = @"\ue61a";
NSString * const dlf_icon_twitter = @"\ue61b";
NSString * const dlf_icon_arrow_left3 = @"\ue632";
NSString * const dlf_icon_arrow_down3 = @"\ue633";
NSString * const dlf_icon_arrow_up3 = @"\ue634";
NSString * const dlf_icon_uniE635 = @"\ue635";
NSString * const dlf_icon_sort_numeric_desc = @"\uf1ed";
NSString * const dlf_icon_sort_numeric_asc = @"\uf1ec";
NSString * const dlf_icon_sort_alpha_desc = @"\uf1e9";
NSString * const dlf_icon_sort_alpha_asc = @"\uf1e8";
NSString * const dlf_icon_unsorted = @"\uf171";
NSString * const dlf_icon_squares = @"\uf022";
NSString * const dlf_icon_menu_sort = @"\ue636";

@implementation NSAttributedString (DelightfulFonts)

+ (NSAttributedString *)symbol:(NSString *)dlf_icon size:(CGFloat)size {
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:dlf_icon attributes:@{NSFontAttributeName: [UIFont fontWithName:@"delightful" size:size]}];
    return attr;
}

@end
