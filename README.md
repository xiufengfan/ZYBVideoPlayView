## ZYBVideoPlayView
An iOS video player use AVPlayer,implement by Swift,support mp4/m3u8

![image](https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0001.png)

![image](https://github.com/zhaoyabei/ZYBVideoPlayView/blob/master/img0002.png)

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
let path = NSBundle.mainBundle().pathForResource("test", ofType: "mp4")
playView.contentURL = NSURL.init(fileURLWithPath: path!)
playView.videoName = "Use ZYBVideoPlayView playing local video"
```
####Play remote file
```
let src = "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
playView.contentURL = NSURL.init(string: src)
playView.videoName = "Use ZYBVideoPlayView playing Remote video"
```