Pod::Spec.new do |s|
  s.name              = 'LyticsUI'
  s.version           = ENV['LIB_VERSION']
  s.summary           = 'UI-specific helpers for the Lytics SDK.'

  s.homepage          = 'https://github.com/lytics/ios-sdk'
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author            = 'Lytics Team'

  s.swift_version     = '5.7'
  s.platform          = :ios, '14.0'

  s.source            = { :git => 'https://github.com/lytics/ios-sdk.git', :tag => s.version.to_s }

  s.documentation_url = 'https://docs.lytics.com/docs/sdk-for-ios'
  s.social_media_url  = 'https://twitter.com/lytics'

  s.dependency          'LyticsSDK', s.version.to_s
  s.source_files      = 'Sources/LyticsUI/**/*.swift'
end
