import 'package:social_share_plugin_platform_interface/social_share_plugin_platform_interface.dart';

SocialSharePluginPlatform get _platform => SocialSharePluginPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

/// Share image to instagram feed
Future<void> shareToFeedInstagram({
  required String path,
  String type = 'image/*',
  OnSuccessHandler? onSuccess,
  OnCancelHandler? onCancel,
}) async {
  return _platform.shareToFeedInstagram(
    path: path,
    type: type,
    onSuccess: onSuccess,
    onCancel: onCancel,
  );
}

/// Share image to facebook feed
Future<void> shareToFeedFacebook({
  required String path,
  String? caption,
  OnSuccessHandler? onSuccess,
  OnCancelHandler? onCancel,
  OnErrorHandler? onError,
}) async {
  return _platform.shareToFeedFacebook(
    path: path,
    caption: caption,
    onSuccess: onSuccess,
    onCancel: onCancel,
    onError: onError,
  );
}

/// Share link to facebook feed
Future<dynamic> shareToFeedFacebookLink({
  required String url,
  String? quote,
  OnSuccessHandler? onSuccess,
  OnCancelHandler? onCancel,
  OnErrorHandler? onError,
}) async {
  return _platform.shareToFeedFacebookLink(
    url: url,
    quote: quote,
    onSuccess: onSuccess,
    onCancel: onCancel,
    onError: onError,
  );
}

/// Share link to twitter feed
Future<dynamic> shareToTwitterLink({
  required String url,
  String? text,
  OnSuccessHandler? onSuccess,
  OnCancelHandler? onCancel,
}) async {
  return _platform.shareToTwitterLink(
    url: url,
    text: text,
    onSuccess: onSuccess,
    onCancel: onCancel,
  );
}
