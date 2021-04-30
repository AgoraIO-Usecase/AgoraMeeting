Pod::Spec.new do |spec|
  spec.name         = "WhiteModule"
  spec.version      = "1.0.0"
  spec.summary      = "White board SDK."
  spec.description  = "White board"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudmeeting-ios/"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudmeeting-ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "WhiteModule/*.{h,m}"
  spec.public_header_files = "WhiteModule/*.h"
  spec.dependency "Whiteboard"
end
