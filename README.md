## ZYBVideoPlayView
An iOS simple video player use AVPlayer,implement by Swift3,support adjust volume, brigtness and seek by slide.

一个iOS端简单播放器，基于AVPlayer（Swift3），支持横屏竖屏切换，支持手势调节音量、屏幕亮度，快进等。

<img src="https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0001.png" width="400" height="300" /> 
<img src="https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0002.png" width="400" height="300" /> 

### Installation

Copy ZYBVideoPlayView folder to your project.

### Usage

#### Init
    
```
let playView = VideoPlayView.init(frame: CGRect(x:0 , y: 0 , width: UIScreen.main.bounds.width , height:UIScreen.main.bounds.width*0.6))
self.view.addSubview(playView)
```

#### Play local file
```        
if let path = Bundle.main.path(forResource: "test", ofType: "mp4"){
	playView.playUrl(path, type: .local)
	playView.title = "playing video file"
}
```
#### Play remote file
```
let src = "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
playView.playUrl(src, type: .Online)
playView.title = "playing live link"
```