source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '6.0'

xcodeproj 'HeroicLabs'

target 'heroiclabs-sdk' do
  pod 'AFNetworking', '~> 2.5'
  pod 'Base64nl', '~> 1.2'
  pod 'PromiseKit/Promise', '~> 1.5'
end

target 'heroiclabs-sdk-tests', :exclusive => true do
  pod 'AFNetworking', '~> 2.5'
  pod 'Base64nl', '~> 1.2'
  pod 'PromiseKit/Promise', '~> 1.5'
  pod 'Expecta', '~> 1.0'
end

link_with 'heroiclabs-sdk', 'heroiclabs-sdk-tests'
