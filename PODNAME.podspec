Pod::Spec.new do |s|
  s.name             = "<PODNAME>"
  s.summary          = "A short description of <PODNAME>."
  s.version          = "0.1.0"
  s.homepage         = "https://github.com/<USERNAME>/<PODNAME>"
  s.license          = 'MIT'
  s.author           = { "<AUTHOR_NAME>" => "<AUTHOR_EMAIL>" }
  s.source           = { :git => "https://github.com/<USERNAME>/<PODNAME>.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/<USERNAME>'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
