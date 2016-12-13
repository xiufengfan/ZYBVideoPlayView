//
//  VideoPlayView.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 2016/12/2.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit
import AVFoundation
let KPlayerStatus = "status"
typealias ZYBActionBlock = () -> Void
let ScreenHeight = UIScreen.mainScreen().bounds.height
let ScreenWidth = UIScreen.mainScreen().bounds.width

enum VideoSourceType {
    case Local,Online
}


class VideoPlayView: UIView ,VideoControlProtocol{
    
    /// title of video
    var title : String?{
        didSet{
            self.controlView.videoNameLabel.text = title
        }
    }
    /// auto start play when load completed,default is true
    var autoStart : Bool = true
    var fullScreenBlock : ZYBActionBlock?
    var exitFullScreenBlock : ZYBActionBlock?
    var loadCompletedBlock : ZYBActionBlock?
    
    
    var videoStatusDelegate : VideoStatusProtocol?

    
    let controlView : VideoControlView
    var isPlaying = false
    var isFullScreen = false
    
    private let player : AVPlayer
    private let playerLayer : AVPlayerLayer
    private var playItem : AVPlayerItem?
    private var oldFrame : CGRect?
    private var oldSuperView : UIView?
    
    private let KFullScreenAnimateDuration = 0.3
    override init(frame: CGRect) {
        
        controlView = VideoControlView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        
        player = AVPlayer.init()
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = controlView.frame
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.layer.addSublayer(playerLayer)
        self.addSubview(controlView)
        controlView.controlledView = self
        self.videoStatusDelegate = controlView

        self.regObserver()
    }
    
    func regObserver(){
        self.player.addPeriodicTimeObserverForInterval(CMTime(value: 1,timescale: 1), queue: dispatch_get_main_queue()) {[weak self] (time) in
            
            if time.timescale != 0{
                self?.videoStatusDelegate?.timeUpdate(time.value/Int64(time.timescale))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Status Change
    
    func sliderBeginTouch(slider : UISlider){
        self.player.pause()
    }
    func sliderTouchCancel(slider : UISlider){
        self.player.play()
    }
    func sliderValueChanged(slider : UISlider){
        if slider.maximumValue == 0 {
            return
        }
        self.playItem?.seekToTime(CMTime(value: CMTimeValue(slider.value),timescale: 1), completionHandler: {[weak self] (res) in
            if res{
                self?.play()
            }
            })
    }


    
    func changeFrame(frame:CGRect){
        self.frame = frame
        self.controlView.frame = self.bounds
        self.controlView.setNeedsLayout()
        self.controlView.layoutIfNeeded()
        self.playerLayer.frame = self.bounds
        
    }
    
    func playButtonAction(playBtn : UIButton){
        if self.controlView.progressSlider.maximumValue == 0 {
            return
        }
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            self.pause()
        }else{
            self.play()
            
        }
    }
    
    
    func replaceContentURL(contentURL : NSURL?){
        
        if contentURL != nil {
            self.player.pause()
            
            self.videoStatusDelegate?.startLoading()
            
            self.playItem?.removeObserver(self, forKeyPath: KPlayerStatus)
            let movieAsset = AVURLAsset.init(URL: contentURL!)
            self.playItem = AVPlayerItem.init(asset: movieAsset)
            self.player.replaceCurrentItemWithPlayerItem(self.playItem!)
            let options = NSKeyValueObservingOptions([.New, .Old])
            playItem?.addObserver(self, forKeyPath: KPlayerStatus, options: options, context: nil)
        }
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print(change)
        print(self.playItem?.status)
        
        if keyPath == KPlayerStatus {
            if self.playItem?.status  == AVPlayerItemStatus.ReadyToPlay {
                self.videoLoadCompleted()
            }
            if self.playItem?.status  == AVPlayerItemStatus.Failed {
                self.videoLoadFailed()
            }
        }
    }
    func videoLoadCompleted(){
        self.videoStatusDelegate?.endLoading()
        self.loadCompletedBlock?()
        if autoStart == true || self.playItem!.duration.timescale == 0{
            self.play()
        }
    }
    
    func videoLoadFailed(){
        self.controlView.progressSlider.maximumValue =  0
        self.controlView.playButton.hidden = false
        self.controlView.indicatorView.hidden = true
        self.controlView.indicatorView.stopAnimating()
        print("video load failed")
    }
    func formatTime(time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        
        
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }
    
    //MARK: --------------Method--------------
    
    func playUrl(videoSource : String , type : VideoSourceType){
        let contentUrl : NSURL?
        
        switch type {
        case .Local:
            contentUrl = NSURL.fileURLWithPath(videoSource)
        case .Online:
            contentUrl = NSURL.init(string: videoSource)
        }
        
        guard contentUrl != nil else {
            //Some warn
            return
        }
        
        replaceContentURL(contentUrl)
    }
    
    func play(){
        
        self.player.play()
        self.controlView.isPlaying = true
        self.controlView.fadeControlBar()
        
    }
    
    func pause(){
        self.player.pause()
        self.controlView.isPlaying = false
        self.controlView.cancelFadeControlBar()
    }

    func fullScreenAction(){
        
        self.oldFrame = self.frame;
        self.oldSuperView = self.superview
        let fullScreenFrame = CGRect(x: 0 , y : 0, width : ScreenWidth, height: ScreenHeight)
        
        var keyWindow = UIApplication.sharedApplication().keyWindow
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().windows[0]
        }
        
        
        UIView.animateWithDuration(KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                keyWindow?.addSubview(self!)
            }
            
            self?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            self?.changeFrame(fullScreenFrame)
            
            
        }) {[weak self] (res) in
            self?.isFullScreen = true
            self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("exit_full_screen"), forState: UIControlState.Normal)
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        }
        
    }
    func exitFullScreenAction(){
        UIView.animateWithDuration(KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                self?.oldSuperView?.addSubview(self!)
                self?.transform = CGAffineTransformMakeRotation(0.0)
                
                self?.changeFrame(self!.oldFrame!)
                
            }
            
        }) {[weak self] (res) in
            self?.isFullScreen = false
            self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), forState: UIControlState.Normal)
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
            
        }
    }

    
    
    
    //MARK:-------VideoControlProtocol---------
    
    func changeScreenStatus(){
        if self.isFullScreen {
            self.exitFullScreenAction()
        }else{
            self.fullScreenAction()
        }
    }
    
    func startDragProgressSlider(progress : UISlider){
        
    }
    
    /// 停止拖拽进度条
    ///
    /// - parameter progress: UISlider
    func endDragProgressSlider(progress : UISlider){
        
    }
    
    
    /// 进度条值变化
    ///
    /// - parameter progress: UISlider
    func progressSliderValueChanged(progress : UISlider){
        
    }
    
    
    /// 播放事件
    func playAction(play:Bool){
        if play {
            self.player.play()
        }else{
            self.player.pause()
        }
    }
    
    /// 进度变化
    ///
    /// - parameter time: 目的进度
    func seekToTime(time : Int){
        self.player.pause()
        self.playItem?.seekToTime(CMTime(value: CMTimeValue(time),timescale: 1), completionHandler: {[weak self] (res) in
            if res{
                self?.player.play()
                self?.videoStatusDelegate?.endLoading()
            }
            })
    }
    
    /// 下一集按钮被按下
    func nextAction(){
        
    }
    
    
    /// 视频总时间
    ///
    /// - returns: Int
    func totalTime()->Int{
        if self.playItem!.duration.timescale != 0 {
            return Int(self.playItem!.duration.value)/Int(self.playItem!.duration.timescale)
        }
        return 0
    }
    


}
