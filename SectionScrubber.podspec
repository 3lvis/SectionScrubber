Pod::Spec.new do |s|
  s.name             = "SectionScrubber"
  s.summary          = "A component to quickly scroll between collection view sections"
  s.version          = "2.0.0"
  s.homepage         = "https://github.com/bakkenbaeck/SectionScrubber"
  s.license          = 'MIT'
  s.author           = { "Bakken & Bæck" => "post@bakkenbaeck.no" }
  s.source           = { :git => "https://github.com/bakkenbaeck/SectionScrubber.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bakkenbaeck'
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'  
  s.requires_arc = true
  s.source_files = 'Sources/**/*'
  s.resources = 'Resources/**/*'
  s.resource_bundles = { 'SectionScrubberResources' => ['Resources/**/*'] }
end
