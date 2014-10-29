#
# Be sure to run `pod lib lint <PODNAME>.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "<PODNAME>"
s.version          = "0.1.0"
s.summary          = "A short description of <PODNAME>."
s.description      = <<-DESC
An optional longer description of <PODNAME>

* Markdown format.
* Don't worry about the indent, we strip it!
DESC
s.homepage         = "https://github.com/<GITHUB_USERNAME>/Podname"
s.license          = 'MIT'
s.author           = { "<AUTHOR_NAME>" => "<AUTHOR_EMAIL>" }
s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/<PODNAME>.git", :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.platform     = :ios, '7.0'
s.requires_arc = true

s.source_files = 'Source/**/*'

# s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
end
