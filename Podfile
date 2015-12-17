source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

xcodeproj 'HeroicLabs'

target 'heroiclabs-sdk' do
  pod 'AFNetworking', '~> 3.0', :inhibit_warnings => true
  pod 'PromiseKit/Promise', '~> 1.6'
end

target 'heroiclabs-sdk-tests', :exclusive => true do
  pod 'AFNetworking', '~> 3.0', :inhibit_warnings => true
  pod 'PromiseKit/Promise', '~> 1.6'
  pod 'Expecta', '~> 1.0', :inhibit_warnings => true
end

link_with 'heroiclabs-sdk', 'heroiclabs-sdk-tests'
