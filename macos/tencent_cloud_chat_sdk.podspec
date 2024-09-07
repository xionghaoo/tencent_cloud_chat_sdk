#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tencent_cloud_chat_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tencent_cloud_chat_sdk'
  s.version          = '8.0.0'
  s.summary          = 'Tencent Cloud Chat SDK For Flutter'
  s.description      = 'Tencent Cloud Chat SDK For Flutter'
  s.homepage         = 'https://trtc.io/products/chat'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tencent' => 'xingchenhe@tencent.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.dependency 'TXIMSDK_Plus_Mac', "8.1.6122"
  s.dependency 'HydraAsync'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
