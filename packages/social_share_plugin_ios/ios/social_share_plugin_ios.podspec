#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'social_share_plugin_ios'
  s.version          = '0.0.1'
  s.summary          = 'An iOS implementation of the social_share_plugin plugin.'
  s.description      = <<-DESC
  An iOS implementation of the social_share_plugin plugin.
                       DESC
  s.homepage         = 'https://github.com/romatroskin/social_share_plugin'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
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
