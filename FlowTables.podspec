Pod::Spec.new do |s|
  s.name         = "FlowTables"
  s.version      = "0.8.1"
  s.summary      = "The great way to create and manage UITableViews in iOS. Forget datasources & delegates"
  s.homepage     = "https://github.com/malcommac/Flow"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "me@danielemargutti.com" }
  s.social_media_url   = "http://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/malcommac/Flow.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
