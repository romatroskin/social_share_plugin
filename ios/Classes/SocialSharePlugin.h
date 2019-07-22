#import <Flutter/Flutter.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface SocialSharePlugin : NSObject<FlutterPlugin, FBSDKSharingDelegate> {
    UIDocumentInteractionController *dic;
    FlutterResult result;
}
@end
