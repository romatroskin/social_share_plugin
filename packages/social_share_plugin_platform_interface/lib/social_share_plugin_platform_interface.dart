import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:social_share_plugin_platform_interface/src/method_channel_social_share_plugin.dart';

/// Callback for the cancel event
typedef OnCancelHandler = Future<void> Function();

/// Callback for the error event
typedef OnErrorHandler = Future<void> Function(String error);

/// Callback for the succees event
typedef OnSuccessHandler = Future<void> Function(String postId);

/// The interface that implementations of social_share_plugin must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `SocialSharePlugin`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [SocialSharePluginPlatform]
/// methods.
abstract class SocialSharePluginPlatform extends PlatformInterface {
  /// Constructs a SocialSharePluginPlatform.
  SocialSharePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocialSharePluginPlatform _instance = MethodChannelSocialSharePlugin();

  /// The default instance of [SocialSharePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSocialSharePlugin].
  static SocialSharePluginPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [SocialSharePluginPlatform] when they register
  /// themselves.
  static set instance(SocialSharePluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

  /// Share image to instagram feed
  Future<void> shareToFeedInstagram({
    required String path,
    String type = 'image/*',
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  });

  /// Share image to facebook feed
  Future<void> shareToFeedFacebook({
    required String path,
    String? caption,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  });

  /// Share link to facebook feed
  Future<dynamic> shareToFeedFacebookLink({
    required String url,
    String? quote,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  });

  /// Share link to twitter feed
  Future<dynamic> shareToTwitterLink({
    required String url,
    String? text,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  });
}
