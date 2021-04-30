Pod::Spec.new do |spec|
  spec.name         = "AgoraRte"
  spec.version      = "1.0.0"
  spec.summary      = "Agora Rte SDK."
  spec.description  = "Scenes, streams, users management"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/common-scene-sdk/"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  
  spec.source = { :http => 'http://localhost:8000/AgoraRte.framework.zip' }
  
  spec.static_framework = true
  spec.vendored_frameworks = "AgoraRte.framework"
  spec.dependency "Armin", "1.0.6"
  spec.dependency "AgoraLog", "1.0.2"
  spec.dependency "YYModel", "1.0.4"
  spec.dependency "AgoraRtm_iOS", "1.4.2"
  spec.dependency "AgoraRtcEngine_iOS", "3.3.0"
  spec.dependency "SSZipArchive", "2.2.3"
  spec.dependency "AliyunOSSiOS"
end
