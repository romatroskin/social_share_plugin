import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_share_plugin_platform_interface/src/method_channel_social_share_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelSocialSharePlugin', () {
    late MethodChannelSocialSharePlugin methodChannelSocialSharePlugin;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelSocialSharePlugin = MethodChannelSocialSharePlugin();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelSocialSharePlugin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            case 'shareToFeedFacebook':
              await methodChannelSocialSharePlugin.methodChannel
                  .invokeMethod('onSuccess', null);
              return null;
            case 'shareToFeedFacebookLink':
              await methodChannelSocialSharePlugin.methodChannel
                  .invokeMethod('onSuccess', null);
              return null;
            case 'shareToFeedInstagram':
              await methodChannelSocialSharePlugin.methodChannel
                  .invokeMethod('onSuccess', null);
              return null;
            case 'shareToTwitterLink':
              await methodChannelSocialSharePlugin.methodChannel
                  .invokeMethod('onSuccess', null);
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName =
          await methodChannelSocialSharePlugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
    test('shareToFeedFacebook', () async {
      await methodChannelSocialSharePlugin.shareToFeedFacebook(
        path: '/test/path',
        caption: 'test caption',
        onSuccess: (postId) async {},
      );
      expect(log, <Matcher>[
        isMethodCall(
          'shareToFeedFacebook',
          arguments: <String, dynamic>{
            'path': '/test/path',
            'caption': 'test caption',
          },
        ),
        isMethodCall(
          'onSuccess',
          arguments: null,
        )
      ]);
    });
    test('shareToFeedFacebookLink', () async {
      await methodChannelSocialSharePlugin.shareToFeedFacebookLink(
        url: 'https://www.test.com',
        quote: 'test quote',
        onSuccess: (postId) async {},
      );
      expect(log, <Matcher>[
        isMethodCall(
          'shareToFeedFacebookLink',
          arguments: <String, dynamic>{
            'url': 'https://www.test.com',
            'quote': 'test quote',
          },
        ),
        isMethodCall(
          'onSuccess',
          arguments: null,
        )
      ]);
    });
    test('shareToFeedInstagram', () async {
      await methodChannelSocialSharePlugin.shareToFeedInstagram(
        path: '/test/path',
        onSuccess: (postId) async {},
      );
      expect(log, <Matcher>[
        isMethodCall(
          'shareToFeedInstagram',
          arguments: <String, dynamic>{
            'path': '/test/path',
            'type': 'image/*',
          },
        ),
        isMethodCall(
          'onSuccess',
          arguments: null,
        )
      ]);
    });
    test('shareToTwitterLink', () async {
      await methodChannelSocialSharePlugin.shareToTwitterLink(
        url: 'https://www.test.com',
        text: 'test text',
        onSuccess: (postId) async {},
      );
      expect(log, <Matcher>[
        isMethodCall(
          'shareToTwitterLink',
          arguments: <String, dynamic>{
            'url': 'https://www.test.com',
            'text': 'test text',
          },
        ),
        isMethodCall(
          'onSuccess',
          arguments: null,
        )
      ]);
    });
  });
}
