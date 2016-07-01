Pod::Spec.new do |s|
  s.name             = "ZYBVideoPlayView"
  s.version          = "1.0.0"
  s.summary          = "An iOS video player use AVPlayer,support mp4/m3u8"
  s.description      = <<-DESC
                       A custom video player on iOS, which implement by Swift.
                       DESC
  s.homepage         = "https://github.com/zhaoyabei/ZYBVideoPlayView"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'LICENSE'
  s.author           = { "赵亚北" => "yabeizhao@126.com" }
  s.source           = { :git => "https://github.com/zhaoyabei/ZYBVideoPlayView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'

  s.platform     = :ios, '7.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'ZYBVideoPlayViewExample/ZYBVideoPlayView'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'AVFoundation', 'UIKit'

end