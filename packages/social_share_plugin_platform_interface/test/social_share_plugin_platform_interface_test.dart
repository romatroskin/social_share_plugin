import 'package:flutter_test/flutter_test.dart';
import 'package:social_share_plugin_platform_interface/social_share_plugin_platform_interface.dart';

class SocialSharePluginMock extends SocialSharePluginPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

  @override
  Future<void> shareToFeedFacebook({
    required String path,
    String? caption,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    if (onSuccess != null) {
      await onSuccess('success');
    }
    return;
  }

  @override
  Future<dynamic> shareToFeedFacebookLink({
    required String url,
    String? quote,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    if (onSuccess != null) {
      await onSuccess('success');
    }
    return;
  }

  @override
  Future<void> shareToFeedInstagram({
    required String path,
    String type = 'image/*',
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    if (onSuccess != null) {
      await onSuccess('success');
    }
    return;
  }

  @override
  Future<dynamic> shareToTwitterLink({
    required String url,
    String? text,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    if (onSuccess != null) {
      await onSuccess('success');
    }
    return;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SocialSharePluginPlatformInterface', () {
    late SocialSharePluginPlatform socialSharePluginPlatform;

    setUp(() {
      socialSharePluginPlatform = SocialSharePluginMock();
      SocialSharePluginPlatform.instance = socialSharePluginPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await SocialSharePluginPlatform.instance.getPlatformName(),
          equals(SocialSharePluginMock.mockPlatformName),
        );
      });
    });
  });
}
