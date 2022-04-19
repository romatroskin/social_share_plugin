#import "SocialSharePlugin.h"
#if __has_include(<social_share_plugin/social_share_plugin-Swift.h>)
#import <social_share_plugin/social_share_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "social_share_plugin-Swift.h"
#endif

@implementation SocialSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSocialSharePlugin registerWithRegistrar:registrar];
}
@end
