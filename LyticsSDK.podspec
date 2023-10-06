Pod::Spec.new do |s|
  s.name              = 'LyticsSDK'
  s.version           = ENV['LIB_VERSION']
  s.summary           = 'SDK for the Lytics customer data platform.'

  s.homepage          = 'https://github.com/lytics/ios-sdk'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author            = 'Lytics Team'

  s.module_name       = 'Lytics'
  s.swift_version     = '5.7'
  s.platform          = :ios, '14.0'

  s.source            = { :git => 'https://github.com/lytics/ios-sdk.git', :tag => s.version.to_s }

  s.documentation_url = 'https://docs.lytics.com/docs/sdk-for-ios'
  s.social_media_url  = 'https://twitter.com/lytics'

  s.dependency          'AnyCodable-FlightSchool', '~> 0.6.0'
  s.source_files      = 'Sources/Lytics/**/*.swift'
end
