Pod::Spec.new do |s|
  s.name             = "Swocket"
  s.version          = "0.1.0"
  s.summary          = "Asynchronous network framework in Swift"
  s.homepage         = "https://github.com/mikaoj/Swocket"
  s.license          = 'MIT'
  s.author           = { "Joakim Gyllström" => "joakim@backslashed.se" }
  s.source           = { :git => "https://github.com/mikaoj/Swocket.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.requires_arc = true

  s.source_files = 'Source/**/*'
end
