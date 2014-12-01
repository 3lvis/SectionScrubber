Pod::Spec.new do |s|
s.name             = "<PODNAME>"
s.version          = "0.1"
s.summary          = "A short description of <PODNAME>."
s.description      = <<-DESC
An optional longer description of <PODNAME>

* Markdown format.
* Don't worry about the indent, we strip it!
DESC
s.homepage         = "https://github.com/hyperoslo/<PODNAME>"
s.license          = 'MIT'
s.author           = { "Hyper AS" => "<AUTHOR_EMAIL>" }
s.source           = { :git => "https://github.com/hyperoslo/<PODNAME>.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/hyperoslo'

s.platform     = :ios, '7.0'
s.requires_arc = true

s.source_files = 'Source/**/*'

# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
