#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'social_share_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Social Share to Facebook and Intagram Flutter plugin.'
  s.description      = <<-DESC
Social Share to Facebook and Intagram Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'TwitterKit'
  s.dependency 'FBSDKCoreKit', '~> 5.5'
  s.dependency 'FBSDKLoginKit', '~> 5.5'
  
  s.dependency 'FBSDKShareKit', '4.44.1'



  s.ios.deployment_target = '9.0'
end

