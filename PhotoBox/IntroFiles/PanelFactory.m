//
//  PanelFactory.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/24/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PanelFactory.h"

#import <MYIntroductionPanel.h>

@interface IntroPanelHeader : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id value;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@implementation IntroPanelHeader

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _type = dictionary[@"type"];
        if ([_type isEqualToString:@"image"]) {
            _value = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dictionary[@"value"]]];
        } else {
            NSString *className = dictionary[@"value"];
            _value = [[NSClassFromString(className) alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [_value setBackgroundColor:[UIColor clearColor]];
        }
    }
    return self;
}

@end

@implementation PanelFactory

+ (NSArray *)panelsForVersion:(NSString *)version {
    NSDictionary *introPlist = [[self class] introPlistForVersion:version];
    NSArray *panelsPlist = [introPlist objectForKey:@"panels"];
    NSMutableArray *panels = [NSMutableArray arrayWithCapacity:panelsPlist.count];
    for (NSDictionary *panel in panelsPlist) {
        MYIntroductionPanel *introPanel = [[self class] panelForDictionary:panel];
        [panels addObject:introPanel];
    }
    return panels;
}

+ (MYIntroductionPanel *)panelForDictionary:(NSDictionary *)dictionary {
    NSString *title = ([((NSString *)dictionary[@"title"]) length]>0)?dictionary[@"title"]:nil;
    NSString *description = ([((NSString *)dictionary[@"description"]) length]>0)?dictionary[@"description"]:nil;
    NSString *image = ([((NSString *)dictionary[@"image"]) length]>0)?dictionary[@"image"]:nil;
    IntroPanelHeader *header = [[IntroPanelHeader alloc] initWithDictionary:dictionary[@"header"]];
    
    NSString *panelClassName = NSStringFromClass([MYIntroductionPanel class]);
    if (dictionary[@"class"] && ((NSString *)dictionary[@"class"]).length > 0) {
        panelClassName = dictionary[@"class"];
    }
    return [[NSClassFromString(panelClassName) alloc] initWithFrame:[[[[UIApplication sharedApplication] delegate] window] bounds] title:title description:description image:(image)?[UIImage imageNamed:image]:nil header:header.value];
}

+ (UIImage *)imageBackgroundForVersion:(NSString *)version {
    NSDictionary *introPlist = [[self class] introPlistForVersion:version];
    NSString *imageName = [introPlist objectForKey:@"backgroundImage"];
    return [UIImage imageNamed:imageName];
}

+ (NSDictionary *)introPlistForVersion:(NSString *)version {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", version]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:version ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    return temp;
}

@end
