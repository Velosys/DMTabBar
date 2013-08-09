Pod::Spec.new do |s|
  s.name         = "DMTabBar"
  s.version      = "0.0.1"
  s.summary      = "XCode 4.x like inspector segmented control."
  s.homepage     = "https://github.com/malcommac/DMTabBar"
  s.license      = { :type => "MIT", :text => "Copyright (c) 2012 Daniele Margutti (http://www.danielemargutti.com - daniele.margutti@gmail.com). All rights reserved."}
  s.author       = { "Daniele Margutti" => "me@danielemargutti.com" }
  s.source       = { :git => "https://github.com/Velosys/DMTabBar.git", :tag => "0.0.1" }
  s.platform     = :osx, '10.6'
  s.source_files = 'DMTabBar/DMTabBar/DMTabBar.{h,m}', 'DMTabBar/DMTabBar/DMTabBarItem.{h,m}'
  s.requires_arc = true
end
