Pod::Spec.new do |s|
  s.name         = "HeroicLabs"
  s.version      = "0.2.0"
  s.summary      = "Heroic Labs SDK for iOS"
  s.description  = "Heroic Labs is a backend for games."
  s.homepage     = "https://heroiclabs.com"
  s.authors      = { "Heroic Labs" => "support@heroiclabs.com"}
  s.social_media_url   = "http://twitter.com/gameupio"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/heroiclabs/heroiclabs-sdk-ios.git", :tag => "0.2.0"}
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.source_files  = "Classes/*.{h,m}"
  s.public_header_files = "Classes/*.h"

  s.requires_arc = true
  s.ios.deployment_target = "6.0"
  s.frameworks    = 'SystemConfiguration', 'MobileCoreServices'

  s.dependency "AFNetworking", "~> 2.5"
  s.dependency "Base64nl", "~> 1.2"
  s.dependency "PromiseKit/Promise", "~> 1.5"
end
