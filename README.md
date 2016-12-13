## ZYBVideoPlayView
An iOS video player use AVPlayer,implement by Swift,support mp4/m3u8


<img src="https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0001.png" width="400" height="300" /> 
<img src="https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0002.png" width="400" height="300" /> 

###Installation

Copy ZYBVideoPlayView folder to your project.

###Usage

#### Init
    
```
let playView = ZYBVideoPlayView.init(frame: CGRect(x:0 , y: 0 , width: UIScreen.mainScreen().bounds.width , height:  UIScreen.mainScreen().bounds.width*0.6))
self.view.addSubview(playView)
```

####Play local file
```        
if let path = NSBundle.mainBundle().pathForResource("test", ofType: "mp4"){
	playView.playUrl(path, type: .Local)
	playView.title = "playing video file"
}
```
####Play remote file
```
let src = "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
playView.playUrl(src, type: .Online)
playView.title = "playing live link"
```