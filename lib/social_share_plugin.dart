import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef Future<dynamic> OnCancelHandler();
typedef Future<dynamic> OnErrorHandler(String? error);
typedef Future<dynamic> OnSuccessHandler(String? postId);

class SocialSharePlugin {
  static const MethodChannel _channel =
      const MethodChannel('social_share_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> shareToFeedInstagram({
    String type = 'image/*',
    required String path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null) {
            onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            onCancel();
          }
          break;
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedInstagram', <String, dynamic>{
      'type': type,
      'path': path,
    });
  }

  static Future<void> shareToFeedFacebookPhoto({
    String? caption,
    String? hashtag,
    String? path,
    String? url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    if (path == null && url == null) {
      throw Exception('path or url is required!');
    }
    if (path != null && url != null) {
      throw Exception('specify only one between path and url!');
    }
    if (path != null && path.startsWith('http')) {
      throw Exception(
          'path must be a local file path, maybe you should use url parameter!');
    }
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null) {
            onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            onCancel();
          }
          break;
        case "onError":
          if (onError != null) {
            onError(call.arguments);
          }
          break;
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    String? filePath = path;
    if (url != null) {
      filePath = await _urlToFilePath(url);
    }
    return _channel.invokeMethod('shareToFeedFacebookPhoto', <String, dynamic>{
      'caption': caption,
      'path': filePath,
      'hashtag': hashtag,
    });
  }

  static Future<void> shareToFeedFacebookVideo({
    String? hashtag,
    String? path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    if (Platform.isAndroid && path == null) {
      throw Exception('path is required!');
    }
    if (Platform.isIOS && path != null) {
      print('WARNING: in shareToFeedFacebookVideo path is not used!');
    }
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null) {
            onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            onCancel();
          }
          break;
        case "onError":
          if (onError != null) {
            onError(call.arguments);
          }
          break;
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedFacebookVideo', <String, dynamic>{
      'path': path,
      'hashtag': hashtag ?? '',
    });
  }

  static Future<dynamic> shareToFeedFacebookLink({
    String? quote,
    String? hashtag,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null) {
            onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            onCancel();
          }
          break;
        case "onError":
          if (onError != null) {
            onError(call.arguments);
          }
          break;
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedFacebookLink', <String, dynamic>{
      'quote': quote,
      'url': url,
      'hashtag': hashtag,
    });
  }

  static Future<bool?> shareToTwitterLink({
    String? text,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSuccess":
          if (onSuccess != null) {
            onSuccess(call.arguments);
          }
          break;
        case "onCancel":
          if (onCancel != null) {
            onCancel();
          }
          break;
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToTwitterLink', <String, dynamic>{
      'text': text,
      'url': url,
    });
  }

  static Future<String> _urlToFilePath(String imageUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filePath = '$tempPath/social_share_plugin_tmp_file';
    File file = new File(filePath);
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
