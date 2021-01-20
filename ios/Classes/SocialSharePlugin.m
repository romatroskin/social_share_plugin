#import "SocialSharePlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//#import <TwitterKit/TWTRKit.h>

@implementation SocialSharePlugin {
    FlutterMethodChannel* _channel;
    UIDocumentInteractionController* _dic;
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
   return [[FBSDKApplicationDelegate sharedInstance]
             application:application
                 openURL:url
       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
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
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink]];
          }
          result(false);
      }
  } else if ([@"shareToFeedFacebook" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          }
          result(false);
      }
  } else if([@"shareToFeedFacebookLink" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShareLink:call.arguments[@"quote"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          }
          result(false);
      }
  } else if([@"shareToTwitterLink" isEqualToString:call.method]) {
      NSURL *twitterURL = [NSURL URLWithString:@"twitter://"];
      if([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
          [self twitterShare:call.arguments[@"text"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *twitterLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id333903271";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterLink]];
          }
          result(false);
      }
  } else {
    result(FlutterMethodNotImplemented);
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
    //Check if user has instagram installed on device
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        NSLog(@"Share error: Instagram not installed");
        //Invoke the "onError" method (like handled in facebook share) with an error string as argument
        [self->_channel invokeMethod:@"onError" arguments:@"Share error: Instagram not installed"];
        return;
    }
    
    //Check authorization for full access in the camera roll
    [self checkCameraRollAuthWithCompletion:^(BOOL fullyAuthorized) {
        if (!fullyAuthorized) {
            NSLog(@"Share error: Missing camera roll access authorization");
            //Invoke the "onError" method (like handled in facebook share) with an error string as argument
            [self->_channel invokeMethod:@"onError" arguments:@"Share error: Missing camera roll access authorization"];
            return;
        }
        
        //Save the image in the camera roll
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
        ];
        
        //Pick the asset from the camera roll (it takes the last saved image in the camera roll)
        PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
        PHAsset *asset = [result firstObject];
        //Retrieve the localIdentifier to be sent to instagram
        NSString *localId = asset.localIdentifier;

        //Build the url to be opened in order to share the image on the instagram feed
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@",localId]];

        //Thread-safe openURL
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:url];
        });

        //Invoke the "onSuccess" method without arguments. It can be useful if you want to handle
        //a success dialog or something else.
        [self->_channel invokeMethod:@"onSuccess" arguments:nil];
    }];
}

- (void)twitterShare:(NSString*)text
                 url:(NSString*)url {
    UIApplication* application = [UIApplication sharedApplication];
    NSString* shareString = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@&url=%@", text, url];
    NSString* escapedShareString = [shareString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL* shareUrl = [NSURL URLWithString:escapedShareString];
    if (@available(iOS 10.0, *)) {
        [application openURL:shareUrl options:@{} completionHandler:^(BOOL success) {
            if(success) {
                [self->_channel invokeMethod:@"onSuccess" arguments:nil];
                NSLog(@"Sending Tweet!");
            } else {
                [self->_channel invokeMethod:@"onCancel" arguments:nil];
                NSLog(@"Tweet sending cancelled");
            }
        }];
    } else {
        [application openURL:shareUrl];
        [self->_channel invokeMethod:@"onSuccess" arguments:nil];
        NSLog(@"Sending Tweet!");
    }
}

/*!
    @brief Check camera roll permissions
 
    @discussion This method check if the application has FULL rights to access camera roll.
    This because with this instagram share method you first need to save the image in the
    camera roll, then retrieve the PHAsset localIdentifier and send it to instagram inside
    the url. After that, a simple openURL do the magic.
 
    @param  completionHandler This handler is called when user give a response on the
    system authorization alert. If he give the full access the BOOL will be true, otherwise
    will be false. 
 */
- (void)checkCameraRollAuthWithCompletion:(void(^_Nonnull)(BOOL fullyAuthorized))completionHandler
 {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                completionHandler(YES);
                break;
            default:
                completionHandler(NO);
                break;
        }
    }];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    [_channel invokeMethod:@"onSuccess" arguments:nil];
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
