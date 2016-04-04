Pod::Spec.new do |s|
  s.version                     = "0.7.2"
  s.source                      = { :git => "https://github.com/heroiclabs/heroiclabs-sdk-ios.git", :tag => "0.7.2"}
  s.name                        = "HeroicLabs"
  s.summary                     = "Heroic Labs SDK for iOS"
  s.description                 = "Heroic Labs is a backend for games."
  s.homepage                    = "https://heroiclabs.com"
  s.authors                     = { "Heroic Labs" => "support@heroiclabs.com"}
  s.social_media_url            = "http://twitter.com/heroicdev"
  s.license                     = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.ios.deployment_target       = '7.0'
  s.tvos.deployment_target      = '9.0'
  s.source_files                = "Classes/*.{h,m}"
  s.public_header_files         = "Classes/*.h"
  s.requires_arc                = true
  s.frameworks                  = 'SystemConfiguration', 'MobileCoreServices'
  s.dependency                  "AFNetworking", "~> 3.1"
  s.dependency                  "PromiseKit/Promise", "~> 1.7"
end
