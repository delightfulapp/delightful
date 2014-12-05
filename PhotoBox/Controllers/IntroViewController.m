//
//  IntroViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "IntroViewController.h"
#import "SeeThroughCircleView.h"

@interface IntroViewController () 
@end

@implementation IntroViewController

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
    
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSDictionary *versionPlist = [self.class introPlistForVersion:currentVersion];
    NSArray *panels = [versionPlist objectForKey:@"panels"];
    NSDictionary *panel = [panels firstObject];
    NSString *description = panel[@"description"];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:[description dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.versionView.text = currentVersion;
    self.whatsNewLabel.attributedText = attr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        PBX_LOG(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    return temp;
}


@end
