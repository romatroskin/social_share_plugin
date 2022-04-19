#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint social_share_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'social_share_plugin'
  s.version          = '0.4.1'
  s.summary          = 'Social Share to Facebook and Intagram Flutter plugin.'
  s.description      = <<-DESC
Social Share to Facebook and Intagram Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/romatroskin/social_share_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'

  s.dependency 'FBSDKCoreKit', '~> 13.1.0'
  s.dependency 'FBSDKShareKit', '~> 13.1.0'

  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
