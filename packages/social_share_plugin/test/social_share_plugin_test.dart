import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:social_share_plugin_platform_interface/social_share_plugin_platform_interface.dart';

class MockSocialSharePluginPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements SocialSharePluginPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialSharePlugin', () {
    late SocialSharePluginPlatform socialSharePluginPlatform;

    setUp(() {
      socialSharePluginPlatform = MockSocialSharePluginPlatform();
      SocialSharePluginPlatform.instance = socialSharePluginPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => socialSharePluginPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => socialSharePluginPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
