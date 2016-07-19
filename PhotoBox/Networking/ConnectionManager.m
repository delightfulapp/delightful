//
//  ConnectionManager.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "ConnectionManager.h"
#import "AFOAuth1Client.h"
#import "APIClient.h"
#import "DownloadedImageManager.h"
#import "FavoritesManager.h"
#import "HintsViewController.h"
#import "TMCache.h"

NSString *baseURLUserDefaultKey = @"photobox.base.url";
NSString *consumerTokenIdentifier = @"photobox.consumer.token";
NSString *oauthTokenIdentifier = @"photobox.oauth.token";
NSString *PhotoBoxAccessTokenDidAcquiredNotification = @"com.photobox.accessTokenDidAcquired";

#define IS_USER_LOGGING_IN_KEY @"IS_USER_LOGGING_IN_KEY"

@implementation ConnectionManager

+ (ConnectionManager *)sharedManager {
    static ConnectionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ConnectionManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenDidFetchNotification:) name:PhotoBoxAccessTokenDidAcquiredNotification object:nil];
    }
    
    return self;
}

- (void)setup {
    AFOAuth1Token *consumerToken = [AFOAuth1Token retrieveCredentialWithIdentifier:consumerTokenIdentifier];
    if (consumerToken) {
        self.consumerToken = consumerToken;
        [[APIClient sharedClient] setConsumerToken:consumerToken];
    } else {
        self.consumerToken = nil;
    }
    AFOAuth1Token *oauthToken = [AFOAuth1Token retrieveCredentialWithIdentifier:oauthTokenIdentifier];
    if (oauthToken) {
        self.oauthToken = oauthToken;
        [[APIClient sharedClient] setAccessToken:oauthToken];
    } else {
        self.oauthToken = nil;
    }
    NSURL *baseURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:baseURLUserDefaultKey]];
    if (baseURL) {
        self.baseURL = baseURL;
    } else {
        self.baseURL = [NSURL URLWithString:@"http://trovebox.com"];
        [self deleteTokens];
        self.consumerToken = [[AFOAuth1Token alloc] initWithKey:@"whatever" secret:@"whatever" session:nil expiration:nil renewable:YES];
        
    }
    
    
}

- (void)connectAsGuest:(NSURL *)url {
    self.isGuestUser = YES;
    [self setBaseURL:url];
    _consumerToken = [[AFOAuth1Token alloc] initWithKey:@"c74a0c32f07dd015328d19d7d8cddc" secret:@"eb6d7e5bbb" session:nil expiration:nil renewable:YES];
    [AFOAuth1Token storeCredential:_consumerToken withIdentifier:consumerTokenIdentifier];
    _oauthToken = [[AFOAuth1Token alloc] initWithKey:@"7fefb2ccfd7c059985c7bad3ccf6e6" secret:@"978a2788c8" session:nil expiration:nil renewable:YES];
    [AFOAuth1Token storeCredential:_oauthToken withIdentifier:oauthTokenIdentifier];
    
    [[APIClient sharedClient] refreshConnectionParameters];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(isUserLoggedIn))];
    _userLoggedIn = _oauthToken?YES:NO;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isUserLoggedIn))];
    
    [self accessTokenDidFetchNotification:nil];
}

- (void)setBaseURL:(NSURL *)baseURL consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret oauthToken:(NSString *)oauthToken oauthSecret:(NSString *)oauthSecret {
    self.baseURL = baseURL;
    if (consumerKey && consumerSecret) {
        self.consumerToken = [[AFOAuth1Token alloc] initWithKey:consumerKey secret:consumerSecret session:nil expiration:nil renewable:YES];
    }
    if (oauthToken && oauthSecret) {
        self.oauthToken = [[AFOAuth1Token alloc] initWithKey:oauthToken secret:oauthSecret session:nil expiration:nil renewable:YES];
    }
}

- (void)setBaseURL:(NSURL *)baseURL {
    if (_baseURL != baseURL) {
        _baseURL = baseURL;
        [[NSUserDefaults standardUserDefaults] setObject:_baseURL.absoluteString forKey:baseURLUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setConsumerToken:(AFOAuth1Token *)consumerToken {
    if (_consumerToken != consumerToken) {
        _consumerToken = consumerToken;
        if (_consumerToken) {
            [AFOAuth1Token storeCredential:_consumerToken withIdentifier:consumerTokenIdentifier];
        }
    }
}

- (void)setOauthToken:(AFOAuth1Token *)oauthToken {
    if (_oauthToken != oauthToken) {
        _oauthToken = oauthToken;
        if (_oauthToken) {
            [AFOAuth1Token storeCredential:_oauthToken withIdentifier:oauthTokenIdentifier];
        }
        [self willChangeValueForKey:NSStringFromSelector(@selector(isUserLoggedIn))];
        _userLoggedIn = _oauthToken?YES:NO;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isUserLoggedIn))];
        
        if (_userLoggedIn) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_USER_LOGGING_IN_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)removeConsumerTokenWithIdentifier:(NSString *)identifier {
    [self removeCredentialWithIdentifier:identifier];
}

- (void)removeOauthTokenWithIdentifier:(NSString *)identifier {
    [self removeCredentialWithIdentifier:identifier];
}

- (void)removeCredentialWithIdentifier:(NSString *)identifier {
    [AFOAuth1Token deleteCredentialWithIdentifier:identifier];
}

- (void)deleteTokens {
    self.oauthToken = nil;
    self.consumerToken = nil;
    [self removeOauthTokenWithIdentifier:oauthTokenIdentifier];
    [self removeConsumerTokenWithIdentifier:consumerTokenIdentifier];
}

- (void)logout {
    [self logoutWithShowingLoginScreen:YES];
}

- (void)logoutWithShowingLoginScreen:(BOOL)show {
    [self deleteTokens];
    self.isGuestUser = NO;
    [[DownloadedImageManager sharedManager] clearHistory];
    [[FavoritesManager sharedManager] clearHistory];
    self.baseURL = nil;
    
    [[TMCache sharedCache] removeAllObjects:nil];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    [self setup];
    
    [[APIClient sharedClient] setAccessToken:nil];
    
    if (show) {
        [self openLoginFromStoryboardWithIdentifier:@"loginViewController"];
    }
}

- (BOOL)isUserLoggingIn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:IS_USER_LOGGING_IN_KEY];
}

- (NSURL *)startOAuthAuthorizationWithServerURL:(NSString *)serverStringURL {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_USER_LOGGING_IN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setBaseURL:[NSURL URLWithString:serverStringURL]];
   // NSAssert([[[[APIClient sharedClient] baseURL] absoluteString] isEqualToString:self.baseURL.absoluteString], @"Expected base url: %@. Actual: %@", self.baseURL.absoluteString, [[[APIClient sharedClient] baseURL] absoluteString]);
    //[[UIApplication sharedApplication] openURL:[[self class] oAuthInitialUrlForServer:serverStringURL]];
    
    return [[self class] oAuthInitialUrlForServer:serverStringURL];
}

- (void)continueOauthAuthorizationWithQuery:(NSString *)query {
    // sample: oauth_consumer_key=c12db8b814d71cf56d1e187ecec048&oauth_consumer_secret=371a5a63fa&oauth_token=a5322075c486ea210c075ae3546403&oauth_token_secret=1f47d2e62e&oauth_verifier=aaa32b81ae
    NSString *consumerKey, *consumerSecret;
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        NSString *variableKey = [keyVal objectAtIndex:0];
        NSString *value = [keyVal lastObject];
        
        // get all details from the request and save it
        if ([variableKey isEqualToString:@"oauth_consumer_key"]){
            consumerKey = value;
        }else if ([variableKey isEqualToString:@"oauth_consumer_secret"]){
            consumerSecret = value;
        }
    }
    AFOAuth1Token *consumerToken = [[AFOAuth1Token alloc] initWithKey:consumerKey secret:consumerSecret session:nil expiration:nil renewable:YES];
    self.consumerToken = consumerToken;
    [[APIClient sharedClient] setConsumerToken:consumerToken];
    
    AFOAuth1Token *requestToken = [[AFOAuth1Token alloc] initWithQueryString:query];
    NSString *verifier = [requestToken.userInfo objectForKey:@"oauth_verifier"];
    [requestToken setVerifier:verifier];
    
    [[APIClient sharedClient] acquireOAuthAccessTokenWithPath:@"/v1/oauth/token/access"
                                                 requestToken:requestToken
                                                 accessMethod:@"POST"
                                                      success:^(AFOAuth1Token *accessToken, id responseObject) {
        self.oauthToken = accessToken;
        [[APIClient sharedClient] setAccessToken:accessToken];
                                        
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoBoxAccessTokenDidAcquiredNotification object:nil];
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authorization Failure", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
        [alert show];
    }];
}

- (void)openLoginFromStoryboardWithIdentifier:(NSString *)storyboardId {
    if (!self.isShowingLoginPage) {
        [self willChangeValueForKey:@"isShowingLoginPage"];
        self.isShowingLoginPage = YES;
        [self didChangeValueForKey:@"isShowingLoginPage"];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:storyboardId];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window.rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)accessTokenDidFetchNotification:(NSNotification *)notification {
    [self willChangeValueForKey:@"isShowingLoginPage"];
    self.isShowingLoginPage = NO;
    [self didChangeValueForKey:@"isShowingLoginPage"];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

+ (NSURL *)oAuthInitialUrlForServer:(NSString *)server {
    NSString *callback = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    NSString *path = [NSString stringWithFormat:@"/v1/oauth/authorize?oauth_callback=%@://&name=", callback];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *fullPath = [[NSString alloc]initWithFormat:@"%@%@%@",server,path,[appName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ;
    
    NSURL *url = [NSURL URLWithString:fullPath];
    return url;
}

+ (NSURL *)oAuthAccessUrlForServer:(NSString *)server {
    NSString* url = [[NSString alloc]initWithFormat:@"%@%@",server,@"/v1/oauth/token/access"];
    return [NSURL URLWithString:url];
}

@end
