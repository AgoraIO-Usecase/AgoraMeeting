Pod::Spec.new do |spec|
  spec.name         = "AgoraRoom"
  spec.version      = "1.0.0"
  spec.summary      = "White board SDK."
  spec.description  = "White board"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudmeeting-ios/"
  spec.license      = "MIT"
  spec.author       = { "Zhuyuping" => "zhuyuping@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudmeeting-ios.git", :tag => "#{spec.version}" }

  spec.static_framework = true
  spec.source_files  = "AgoraRoom/**/*.{h,m}"
  spec.public_header_files = "AgoraRoom/*.h",  "AgoraRoom/**/*.h"
  spec.dependency "AgoraRte"
  spec.dependency "AgoraLog"
  spec.dependency "AFNetworking", "4.0.1"
  spec.dependency "YYModel", "1.0.4"
  spec.dependency "CocoaLumberjack", "3.6.2"
  spec.dependency "SSZipArchive", "2.2.3"
  spec.dependency "AliyunOSSiOS", "2.10.8"
end
