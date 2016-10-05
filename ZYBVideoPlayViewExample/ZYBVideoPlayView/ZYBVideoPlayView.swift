//
//  ZYBVideoPlayView.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 16/6/30.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit
import AVFoundation
let KPlayerStatus = "status"
typealias ZYBActionBlock = () -> Void
let ScreenHeight = UIScreen.mainScreen().bounds.height
let ScreenWidth = UIScreen.mainScreen().bounds.width

class ZYBVideoPlayView: UIView {
        /// url of video
    var contentURL : NSURL?{
        didSet{
            self.reloadContentURL()
        }
    }
        /// title of video
    var videoName : String?{
        didSet{
            self.controlView.videoNameLabel.text = videoName
        }
    }
        /// auto start play when load completed,default is true
    var autoStart : Bool = true
    var fullScreenBlock : ZYBActionBlock?
    var exitFullScreenBlock : ZYBActionBlock?
    var loadCompletedBlock : ZYBActionBlock?
    
    let controlView : ZYBVideoPlayControlView
    var isPlaying = false
    var isFullScreen = false
    
    private let player : AVPlayer
    private let playerLayer : AVPlayerLayer
    private var playItem : AVPlayerItem?
    private var oldFrame : CGRect?
    private var oldSuperView : UIView?

    private let KFullScreenAnimateDuration = 0.3
    override init(frame: CGRect) {
        
        controlView = ZYBVideoPlayControlView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        player = AVPlayer.init()
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = controlView.frame
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.layer.addSublayer(playerLayer)
        self.addSubview(controlView)
        self.regObserver()
    }
    
    func regObserver(){
        self.player.addPeriodicTimeObserverForInterval(CMTime(value: 1,timescale: 1), queue: dispatch_get_main_queue()) {[weak self] (time) in
            self?.timeChange(time)
        }
        self.controlView.progressSlider.addTarget(self, action: #selector(ZYBVideoPlayView.sliderValueChanged(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.controlView.progressSlider.addTarget(self, action: #selector(ZYBVideoPlayView.sliderValueChanged(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        self.controlView.progressSlider.addTarget(self, action: #selector(ZYBVideoPlayView.sliderBeginTouch(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.controlView.progressSlider.addTarget(self, action: #selector(ZYBVideoPlayView.sliderTouchCancel(_:)), forControlEvents: UIControlEvents.TouchCancel)
        self.controlView.fullScreenButton.addTarget(self, action: #selector(ZYBVideoPlayView.changeScreenStatus), forControlEvents: UIControlEvents.TouchUpInside)
        self.controlView.playButton.addTarget(self, action: #selector(ZYBVideoPlayView.playButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
    func timeChange(time:CMTime){
        let currentTime = Int(time.value)/Int(time.timescale)
        self.controlView.progressSlider.value = Float(currentTime)
        let minutesElapsed = Float(currentTime)/60.0
        let secondsElapsed = fmod(Float(currentTime), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        self.controlView.startTimeLabel.text = timeElapsedString as String
    }
    func changeScreenStatus(){
        if self.isFullScreen {
            self.exitFullScreenAction()
        }else{
            self.fullScreenAction()
        }
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
    
    
    func reloadContentURL(){
        
        if self.contentURL != nil {
            self.player.pause()
            self.controlView.isPlaying = false
            self.controlView.playButton.hidden = true
            self.controlView.cancelFadeControlBar()
            self.controlView.indicatorView.hidden = false
            self.controlView.indicatorView.startAnimating()

            self.playItem?.removeObserver(self, forKeyPath: KPlayerStatus)
            let movieAsset = AVURLAsset.init(URL: self.contentURL!)
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
        var totalTime = 0
        if self.playItem!.duration.timescale != 0 {
            totalTime = Int(self.playItem!.duration.value)/Int(self.playItem!.duration.timescale)
        }
        self.controlView.totalTimeLabel.text = self.formatTime(totalTime)
        self.controlView.progressSlider.maximumValue =  Float(totalTime)
        self.loadCompletedBlock?()
        self.controlView.playButton.hidden = false
        self.controlView.indicatorView.hidden = true
        self.controlView.indicatorView.stopAnimating()
        self.controlView.show()
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
    
    //MARK: Method
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


}
