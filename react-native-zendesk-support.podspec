
Pod::Spec.new do |s|
  s.name = react-native-zendesk-support
  s.license = package[:license]
  s.authors = ryan l kuhn
  s.summary = package[:description]
  s.source = { :git => 'https://github.com/ryanlkuhn/react-native-zendesk-support.git',  :tag => 'v'+s.version.to_s }
  s.homepage = 'https://github.com/ryanlkuhn/react-native-zendesk-support'
  s.source_files   = 'ios/RNZenDeskSupport.{h,m}'

  s.platform = :ios, "8.0"

  s.dependency 'ZendeskSDK'
  s.dependency 'React'
  s.ios.xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/ZendeskSDK"',
    'OTHER_LDFLAGS' => '-framework ZendeskSDK'
  }
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }


end