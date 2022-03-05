#import <Flutter/Flutter.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h> // needed for video types

@interface SocialSharePlugin : NSObject <FlutterPlugin, FBSDKSharingDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
}
@end
