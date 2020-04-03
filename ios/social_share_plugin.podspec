#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'social_share_plugin'
  s.version          = '0.3.1'
  s.summary          = 'Social Share to Facebook and Intagram Flutter plugin.'
  s.description      = <<-DESC
Social Share to Facebook and Intagram Flutter plugin.
                       DESC
  s.homepage         = 'http://github.com/romatroskin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Roman Matroskin' => 'romatroskin@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit'
  s.dependency 'FBSDKShareKit'


  s.ios.deployment_target = '9.0'
end

