//
//  SharerManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ShareType) {
    ShareTypeSMS,
    ShareTypeEmail,
    ShareTypeFacebook,
    ShareTypeTwitter
};

@interface SharerManager : NSObject

+ (void)shareTo:(ShareType)service URL:(NSURL *)URL text:(NSString *)text subject:(NSString *)subject;

@end
