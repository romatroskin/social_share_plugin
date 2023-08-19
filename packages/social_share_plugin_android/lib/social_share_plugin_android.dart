import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:social_share_plugin_platform_interface/social_share_plugin_platform_interface.dart';

/// The Android implementation of [SocialSharePluginPlatform].
class SocialSharePluginAndroid extends SocialSharePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('social_share_plugin_android');

  /// Registers this class as the default instance of
  /// [SocialSharePluginPlatform]
  static void registerWith() {
    SocialSharePluginPlatform.instance = SocialSharePluginAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<void> shareToFeedFacebook({
    required String path,
    String? caption,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onSuccess':
          return onSuccess != null
              ? onSuccess(call.arguments as String)
              : Future.value();
        case 'onCancel':
          return onCancel != null ? onCancel() : Future.value();
        case 'onError':
          return onError != null
              ? onError(call.arguments as String)
              : Future.value();
        default:
          throw UnsupportedError('Unknown method called');
      }
    });
    return methodChannel.invokeMethod('shareToFeedFacebook', <String, dynamic>{
      'caption': caption,
      'path': path,
    });
  }

  @override
  Future<dynamic> shareToFeedFacebookLink({
    required String url,
    String? quote,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onSuccess':
          return onSuccess != null
              ? onSuccess(call.arguments as String)
              : Future.value();
        case 'onCancel':
          return onCancel != null ? onCancel() : Future.value();
        case 'onError':
          return onError != null
              ? onError(call.arguments as String)
              : Future.value();
        default:
          throw UnsupportedError('Unknown method called');
      }
    });
    return methodChannel
        .invokeMethod('shareToFeedFacebookLink', <String, dynamic>{
      'quote': quote,
      'url': url,
    });
  }

  @override
  Future<void> shareToFeedInstagram({
    required String path,
    String type = 'image/*',
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onSuccess':
          return onSuccess != null
              ? onSuccess(call.arguments as String)
              : Future.value();
        case 'onCancel':
          return onCancel != null ? onCancel() : Future.value();
        default:
          throw UnsupportedError('Unknown method called');
      }
    });
    return methodChannel.invokeMethod('shareToFeedInstagram', <String, dynamic>{
      'type': type,
      'path': path,
    });
  }

  @override
  Future<dynamic> shareToTwitterLink({
    required String url,
    String? text,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) {
    methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onSuccess':
          return onSuccess != null
              ? onSuccess(call.arguments as String)
              : Future.value();
        case 'onCancel':
          return onCancel != null ? onCancel() : Future.value();
        //  case "onError":
        //    return onError(call.arguments);
        default:
          throw UnsupportedError('Unknown method called');
      }
    });
    return methodChannel.invokeMethod('shareToTwitterLink', <String, dynamic>{
      'text': text,
      'url': url,
    });
  }
}
