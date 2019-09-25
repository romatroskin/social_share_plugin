#import "SocialSharePlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TWTRKit.h>

@implementation SocialSharePlugin {
    FlutterMethodChannel* _channel;
    FBSDKLoginManager* _loginManager;
    UIDocumentInteractionController* _dic;
    NSString* _token;
    NSString* _quote;
    NSString* _url;
    FlutterResult _result;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"social_share_plugin"
            binaryMessenger:[registrar messenger]];
  SocialSharePlugin* instance = [[SocialSharePlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
    self = [super init];
    if(self) {
        _channel = channel;
        _loginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [[FBSDKApplicationDelegate sharedInstance] application:application
                           didFinishLaunchingWithOptions:launchOptions];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  BOOL handled = [[FBSDKApplicationDelegate sharedInstance]
            application:application
                openURL:url
      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
             annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
  return handled || [[Twitter sharedInstance] application:application openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
  BOOL handled =
      [[FBSDKApplicationDelegate sharedInstance] application:application
                                                     openURL:url
                                           sourceApplication:sourceApplication
                                                  annotation:annotation];
  return handled;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _result = result;
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"shareToFeedInstagram" isEqualToString:call.method]) {
      NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
      if([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
          [self instagramShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *instagramLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id389801252";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink]];
          result(false);
      }
  } else if ([@"shareToFeedFacebook" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
  } else if([@"shareToFeedFacebookLink" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
          bool isLoggedIn = accessToken != nil && !accessToken.expired;
          if(isLoggedIn) {
              _token = accessToken.tokenString;
              [self facebookShareLink:call.arguments[@"quote"] url:call.arguments[@"url"]];
              result(nil);
          } else {
              UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
              _quote = call.arguments[@"quote"];
              _url = call.arguments[@"url"];
              [_loginManager logInWithPermissions:@[@"email"] fromViewController:controller handler:^(FBSDKLoginManagerLoginResult *loginResult,
                                                                                                                                NSError *error) {
                  [self handleLoginResult:loginResult
                                   result:result
                                    error:error];
              }];
          }
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
  } else if([@"shareToTwitter" isEqualToString:call.method]) {
      NSURL *twitterURL = [NSURL URLWithString:@"twitter://"];
      if([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
          [self twitterShare:call.arguments[@"text"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id333903271";
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          result(false);
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleLoginResult:(FBSDKLoginManagerLoginResult *)loginResult
                   result:(FlutterResult)result
                    error:(NSError *)error {
    if(error == nil) {
        if(!loginResult.isCancelled) {
            _token = loginResult.token.tokenString;
            [self facebookShareLink:_quote url:_url];
            _result(nil);
        } else {
            [_channel invokeMethod:@"onCancel" arguments:nil];
            _result(nil);
        }
    } else {
        [_channel invokeMethod:@"onError" arguments:nil];
        _result(nil);
    }
}

- (void)facebookShare:(NSString*)imagePath {
    //NSURL* path = [[NSURL alloc] initWithString:call.arguments[@"path"]];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)facebookShareLink:(NSString*)quote
                      url:(NSString*)url {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.quote = quote;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)instagramShare:(NSString*)imagePath {
    NSError *error = nil;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [[NSFileManager defaultManager] moveItemAtPath:imagePath toPath:[NSString stringWithFormat:@"%@.igo", imagePath] error:&error];
    NSURL *path = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@.igo", imagePath]];
    _dic = [UIDocumentInteractionController interactionControllerWithURL:path];
    _dic.UTI = @"com.instagram.exclusivegram";
    if (![_dic presentOpenInMenuFromRect:CGRectZero inView:controller.view animated:TRUE]) {
        NSLog(@"Error sharing to instagram");
    };
}

- (void)twitterShare:(NSString*)text
                 url:(NSString*)url {
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:text];
    [composer setURL:[NSURL URLWithString:url]];
    [composer showFromViewController:controller completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            [self->_channel invokeMethod:@"onCancel" arguments:nil];
            NSLog(@"Tweet composition cancelled");
        }
        else {
            [self->_channel invokeMethod:@"onSuccess" arguments:nil];
            NSLog(@"Sending Tweet!");
        }
    }];
    
//    if ([[Twitter sharedInstance].sessionStore hasLoggedInUsers]) {
//        TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
//        [controller presentViewController:composer animated:YES completion:nil];
//    } else {
//        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
//            if (session) {
//                TWTRComposerViewController *composer = [TWTRComposerViewController emptyComposer];
//                [controller presentViewController:composer animated:YES completion:nil];
//            } else {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Twitter Accounts Available" message:@"You must log in before presenting a composer." preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//                [alert addAction:ok];
//                [controller presentViewController:alert animated:YES completion:nil];
//            }
//        }];
//    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    [_channel invokeMethod:@"onSuccess" arguments:_token];
    NSLog(@"Sharing completed successfully");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    [_channel invokeMethod:@"onCancel" arguments:nil];
    NSLog(@"Sharing cancelled");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    [_channel invokeMethod:@"onError" arguments:nil];
    NSLog(@"%@",error);
}

@end
