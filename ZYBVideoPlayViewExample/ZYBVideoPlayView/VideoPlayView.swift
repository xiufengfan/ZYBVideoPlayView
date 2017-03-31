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
let ScreenHeight = UIScreen.main.bounds.height
let ScreenWidth = UIScreen.main.bounds.width

enum VideoSourceType {
    case local,online
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
    
    fileprivate let player : AVPlayer
    fileprivate let playerLayer : AVPlayerLayer
    fileprivate var playItem : AVPlayerItem?
    fileprivate var oldFrame : CGRect?
    fileprivate var oldSuperView : UIView?
    
    fileprivate let KFullScreenAnimateDuration = 0.3
    override init(frame: CGRect) {
        
        controlView = VideoControlView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        
        player = AVPlayer.init()
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = controlView.frame
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.layer.addSublayer(playerLayer)
        self.addSubview(controlView)
        controlView.controlledView = self
        self.videoStatusDelegate = controlView

        self.regObserver()
    }
    
    func regObserver(){
        self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1,timescale: 1), queue: DispatchQueue.main) {[weak self] (time) in
            
            if time.timescale != 0{
                self?.videoStatusDelegate?.timeUpdate(time.value/Int64(time.timescale))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Status Change
    
    func sliderBeginTouch(_ slider : UISlider){
        self.player.pause()
    }
    func sliderTouchCancel(_ slider : UISlider){
        self.player.play()
    }
    func sliderValueChanged(_ slider : UISlider){
        if slider.maximumValue == 0 {
            return
        }
        self.playItem?.seek(to: CMTime(value: CMTimeValue(slider.value),timescale: 1), completionHandler: {[weak self] (res) in
            if res{
                self?.play()
            }
            })
    }


    
    func changeFrame(_ frame:CGRect){
        self.frame = frame
        self.controlView.frame = self.bounds
        self.controlView.setNeedsLayout()
        self.controlView.layoutIfNeeded()
        self.playerLayer.frame = self.bounds
        
    }
    
    func playButtonAction(_ playBtn : UIButton){
        if self.controlView.progressSlider.maximumValue == 0 {
            return
        }
        if ((self.player.rate != 0) && (self.player.error == nil)) {
            self.pause()
        }else{
            self.play()
            
        }
    }
    
    
    func replaceContentURL(_ contentURL : URL?){
        
        if contentURL != nil {
            self.player.pause()
            
            self.videoStatusDelegate?.startLoading()
            
            self.playItem?.removeObserver(self, forKeyPath: KPlayerStatus)
            let movieAsset = AVURLAsset.init(url: contentURL!)
            self.playItem = AVPlayerItem.init(asset: movieAsset)
            self.player.replaceCurrentItem(with: self.playItem!)
            let options = NSKeyValueObservingOptions([.new, .old])
            playItem?.addObserver(self, forKeyPath: KPlayerStatus, options: options, context: nil)
        }
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == KPlayerStatus {
            if self.playItem?.status  == AVPlayerItemStatus.readyToPlay {
                self.videoLoadCompleted()
            }
            if self.playItem?.status  == AVPlayerItemStatus.failed {
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
        self.controlView.playButton.isHidden = false
        self.controlView.indicatorView.isHidden = true
        self.controlView.indicatorView.stopAnimating()
        print("video load failed")
    }
    func formatTime(_ time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        
        
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }
    
    //MARK: --------------Method--------------
    
    func playUrl(_ videoSource : String , type : VideoSourceType){
        let contentUrl : URL?
        
        switch type {
        case .local:
            contentUrl = URL(fileURLWithPath: videoSource)
        case .online:
            contentUrl = URL.init(string: videoSource)
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
        
        var keyWindow = UIApplication.shared.keyWindow
        if keyWindow == nil {
            keyWindow = UIApplication.shared.windows[0]
        }
        
        
        UIView.animate(withDuration: KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                keyWindow?.addSubview(self!)
            }
            
            self?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            
            self?.changeFrame(fullScreenFrame)
            
            
        }, completion: {[weak self] (res) in
            self?.isFullScreen = true
            self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("exit_full_screen"), for: UIControlState())
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        }) 
        
    }
    func exitFullScreenAction(){
        UIView.animate(withDuration: KFullScreenAnimateDuration, animations: { [weak self] in
            if self != nil{
                self?.oldSuperView?.addSubview(self!)
                self?.transform = CGAffineTransform(rotationAngle: 0.0)
                
                self?.changeFrame(self!.oldFrame!)
                
            }
            
        }, completion: {[weak self] (res) in
            self?.isFullScreen = false
            self?.controlView.fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), for: UIControlState())
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
            
        }) 
    }

    
    
    
    //MARK:-------VideoControlProtocol---------
    
    func changeScreenStatus(){
        if self.isFullScreen {
            self.exitFullScreenAction()
        }else{
            self.fullScreenAction()
        }
    }
    
    func startDragProgressSlider(_ progress : UISlider){
        
    }
    
    /// 停止拖拽进度条
    ///
    /// - parameter progress: UISlider
    func endDragProgressSlider(_ progress : UISlider){
        
    }
    
    
    /// 进度条值变化
    ///
    /// - parameter progress: UISlider
    func progressSliderValueChanged(_ progress : UISlider){
        
    }
    
    
    /// 播放事件
    func playAction(_ play:Bool){
        if play {
            self.player.play()
        }else{
            self.player.pause()
        }
    }
    
    /// 进度变化
    ///
    /// - parameter time: 目的进度
    func seekToTime(_ time : Int){
        self.player.pause()
        self.playItem?.seek(to: CMTime(value: CMTimeValue(time),timescale: 1), completionHandler: {[weak self] (res) in
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
