import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_share_plugin_ios/social_share_plugin_ios.dart';
import 'package:social_share_plugin_platform_interface/social_share_plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialSharePluginIOS', () {
    const kPlatformName = 'iOS';
    late SocialSharePluginIOS socialSharePlugin;
    late List<MethodCall> log;

    setUp(() async {
      socialSharePlugin = SocialSharePluginIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(socialSharePlugin.methodChannel,
              (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      SocialSharePluginIOS.registerWith();
      expect(SocialSharePluginPlatform.instance, isA<SocialSharePluginIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await socialSharePlugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
