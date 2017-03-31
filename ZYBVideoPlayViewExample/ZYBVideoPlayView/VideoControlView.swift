//
//  VideoControlView.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 2016/12/2.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit

extension UIImage{
    class func localImageWithName(_ name:String)->UIImage?{
        if let path = Bundle.main.path(forResource: name, ofType: "png"){
            return UIImage.init(contentsOfFile: path)
        }
        return nil
    }
}

class VideoControlView: UIView ,VideoStatusProtocol{

    var controlledView : VideoControlProtocol?
    
    //
    fileprivate let kVideoControlTopBarHeight : CGFloat = 44.0
    fileprivate let kVideoControlBottomBarHeight : CGFloat = 44.0
    fileprivate let kVideoControlPlayBtnWidth : CGFloat = 60.0
    fileprivate let kVideoControlTimeLabelWidth : CGFloat = 50.0
    fileprivate let kVideoControlTimeLabelFontSize : CGFloat = 10.0
    fileprivate let kVideoControlVideoNameLabelFontSize : CGFloat = 16.0
    fileprivate let kVideoControlAnimationTimeinterval = 0.4
    fileprivate let kVideoControlAutoHiddenTime = 3.0
    fileprivate let kPanDistance : CGFloat = 100.0
    fileprivate let KPerPanMove  : Float = 1.0

    let topBar : UIView
    let bottomBar : UIView
    let playButton : UIButton
    let fullScreenButton : UIButton
    let progressSlider : UISlider
    let startTimeLabel : UILabel
    let totalTimeLabel : UILabel
    let videoNameLabel : UILabel
    let backButton : UIButton
    let indicatorView : UIActivityIndicatorView

    
    /// 选集
    var selectBlock : ZYBResultBlock?
    
    /// 切换清晰度
    var changeQualityBlock : ZYBResultBlock?
    
    
    /// 快进快退指示视图
    let progressView : PlayerProgressView
    
    
    let pan : UIPanGestureRecognizer
    
    fileprivate var panIsVertical = true
    fileprivate var startPanTime : Float = 0

    var isPlaying = false{
        didSet{
            var name : String
            if isPlaying {
                name = "btn_pause"
            }else{
                name = "btn_play"
                
            }
            playButton.setBackgroundImage(UIImage.localImageWithName(name), for: UIControlState())
        }
    }
    var isShowing = true
    
    var editing = false
    
    
    func hide(){
        if !isShowing {
            return
        }
        if self.isPlaying == false{
            return
        }
        
        if self.editing == true{
            return
        }
        self.hideDirect()
    }
    
    
    /// 没有判断条件，直接隐藏
    func hideDirect(){
        UIView.animate(withDuration: kVideoControlAnimationTimeinterval, animations: { [weak self] in
            self?.topBar.alpha = 0.0
            self?.bottomBar.alpha = 0.0
            self?.playButton.alpha = 0.0
        }, completion: { [weak self] (res) in
            self?.isShowing = false
        }) 
    }
    
    func show(){
        if isShowing {
            return;
        }
        
        UIView.animate(withDuration: kVideoControlAnimationTimeinterval, animations: { [weak self] in
            self?.topBar.alpha = 1.0
            self?.bottomBar.alpha = 1.0
            self?.playButton.alpha = 1.0
        }, completion: { [weak self] (res) in
            self?.isShowing = true
            self?.fadeControlBar()
        }) 
    }
    func fadeControlBar(){
        if !self.isShowing {
            return;
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(VideoControlView.hide), object: nil)
        self.perform(#selector(VideoControlView.hide), with: nil, afterDelay: kVideoControlAutoHiddenTime)
    }
    func cancelFadeControlBar(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(VideoControlView.hide), object: nil)
    }
    
    
    
     override init(frame: CGRect) {
        
        pan = UIPanGestureRecognizer()

        topBar = UIView()
        topBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        playButton = UIButton.init(type: UIButtonType.custom)
        playButton.setBackgroundImage(UIImage.localImageWithName("btn_play"), for: UIControlState())
        
        fullScreenButton = UIButton.init(type: UIButtonType.custom)
        fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), for: UIControlState())
        fullScreenButton.frame = CGRect(x: 0,y: 0,width: kVideoControlBottomBarHeight,height: kVideoControlBottomBarHeight)
        
        progressSlider = UISlider()
        progressSlider.isContinuous = true
        startTimeLabel = UILabel()
        startTimeLabel.font = UIFont.systemFont(ofSize: kVideoControlTimeLabelFontSize)
        startTimeLabel.textColor = UIColor.white
        startTimeLabel.textAlignment = NSTextAlignment.center
        
        totalTimeLabel = UILabel()
        totalTimeLabel.font = UIFont.systemFont(ofSize: kVideoControlTimeLabelFontSize)
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.textAlignment = NSTextAlignment.center
        
        videoNameLabel = UILabel()
        videoNameLabel.font = UIFont.systemFont(ofSize: kVideoControlVideoNameLabelFontSize)
        videoNameLabel.textColor = UIColor.white
        
        backButton = UIButton.init(type: UIButtonType.custom)
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        
        progressView = Bundle.main.loadNibNamed("PlayerProgressView", owner: nil, options: nil)![0] as! PlayerProgressView
        progressView.frame = CGRect(x: 0, y: 0, width: 140, height: 100)
        progressView.isHidden = true
        
        
        super.init(frame: frame)
        
        topBar.addSubview(videoNameLabel)
        bottomBar.addSubview(startTimeLabel)
        bottomBar.addSubview(progressSlider)
        bottomBar.addSubview(totalTimeLabel)
        bottomBar.addSubview(fullScreenButton)
        
        self.addSubview(topBar)
        self.addSubview(indicatorView)
        self.addSubview(playButton)
        self.addSubview(bottomBar)
        self.addSubview(progressView)
        progressView.center = self.center
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(VideoControlView.onTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        
        pan.addTarget(self, action: #selector(VideoControlView.panAction(_:)))
        self.addGestureRecognizer(pan)
        
        self.regObserver()
        
    }
    
    func regObserver(){
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchUp(_:)), for: UIControlEvents.touchUpInside)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchUp(_:)), for: UIControlEvents.touchUpOutside)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderBeginTouch(_:)), for: UIControlEvents.touchDown)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchCancel(_:)), for: UIControlEvents.touchCancel)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        self.fullScreenButton.addTarget(self, action: #selector(VideoControlView.changeScreenStatus), for: UIControlEvents.touchUpInside)
        self.playButton.addTarget(self, action: #selector(VideoControlView.playButtonAction(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topBar.frame = CGRect(x : self.bounds.minX, y : self.bounds.minY, width:  self.bounds.maxX, height : kVideoControlTopBarHeight);
        self.videoNameLabel.frame = CGRect(x: 10, y: 0, width: self.topBar.frame.size.width, height: self.topBar.frame.size.height);
        self.backButton.frame = CGRect(x: 0, y: 0, width: kVideoControlTopBarHeight, height: kVideoControlTopBarHeight);
        
        self.bottomBar.frame = CGRect(x: self.bounds.minX, y: self.bounds.maxY - kVideoControlBottomBarHeight, width: self.bounds.maxX, height: kVideoControlBottomBarHeight);
        
        self.playButton.frame = CGRect( x: self.frame.size.width/2-kVideoControlPlayBtnWidth/2, y: self.frame.size.height/2-kVideoControlPlayBtnWidth/2 , width: kVideoControlPlayBtnWidth,height: kVideoControlPlayBtnWidth);
        
        self.fullScreenButton.frame = CGRect(x: self.bottomBar.bounds.maxX - self.fullScreenButton.bounds.width, y: self.bottomBar.bounds.height/2 - self.fullScreenButton.bounds.height/2, width: kVideoControlBottomBarHeight, height: kVideoControlBottomBarHeight);
        
        self.progressSlider.frame = CGRect(x: kVideoControlTimeLabelWidth, y: self.bottomBar.bounds.maxY/2 - self.progressSlider.bounds.maxY/2, width: self.bounds.maxX - kVideoControlTimeLabelWidth*2  - self.fullScreenButton.bounds.maxX, height: self.progressSlider.bounds.maxY);
        
        self.startTimeLabel.frame = CGRect(x: 0, y: 0, width: kVideoControlTimeLabelWidth, height: self.bottomBar.frame.height);
        
        self.totalTimeLabel.frame = CGRect(x: self.fullScreenButton.frame.minX-kVideoControlTimeLabelWidth, y: self.startTimeLabel.frame.minY, width: kVideoControlTimeLabelWidth,  height: self.bottomBar.frame.height);
        self.indicatorView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        
        self.progressView.frame = CGRect(x: 0, y: 0, width: 140, height: 100)
        self.progressView.center = self.center

    }
    
    func onTap(_ tap : UITapGestureRecognizer){
        if isShowing {
            self.hideDirect()
        }else{
            self.show()
        }
    }
    
    /// 滑动手势
    ///
    /// - parameter ges: UIPanGestureRecognizer
    func panAction(_ ges : UIPanGestureRecognizer){
        let ve = ges.velocity(in: self)
        
        switch ges.state {
            
        case .began:
            panIsVertical = abs(ve.x) < abs(ve.y)
            startPanTime = self.progressSlider.value
            
        case .changed:
            guard abs(ve.x)>kPanDistance || abs(ve.y) > kPanDistance else {
                return
            }
            if panIsVertical {
                if (abs(ve.y) > kPanDistance) {
                    //左侧 亮度
                    if ges.location(in: self).x<200 {
                        if (ve.y > kPanDistance) {
                            UIScreen.main.brightness -= 0.01;
                        }
                        if (ve.y < -kPanDistance){
                            UIScreen.main.brightness += 0.01;
                        }
                    }
                    
                    //右侧,音量
                    if (ges.location(in: self).x > self.frame.width-200) {
                        if (ve.y > kPanDistance) {
                            //                NSLog(@"down");
                            //                [DeviceTool lowerVolume];
                            
                        }
                        if (ve.y < -kPanDistance){
                            //                NSLog(@"up");
                            //                [DeviceTool addVolume];
                        }
                    }
                }
            }else{
                if abs(ve.x) > kPanDistance{
                    self.editing = true
                    //右滑
                    if ve.x > kPanDistance {
                        //                    print("--------右滑")
                        self.progressView.isHidden = false
                        self.progressSlider.value += KPerPanMove
                        sliderValueChanged(self.progressSlider)
                        self.progressView.isFastForwarding = true
                        progerssViewTimeUpdate()
                        return
                    }
                    
                    //左滑
                    if ve.x < -kPanDistance {
                        //                    print("--------左滑")
                        self.progressView.isHidden = false
                        self.progressSlider.value -= KPerPanMove
                        sliderValueChanged(self.progressSlider)
                        self.progressView.isFastForwarding = false
                        progerssViewTimeUpdate()
                        return
                    }
                }
            }
            break
            
        case .ended:
            self.editing = false
            if panIsVertical == false{
                self.progressView.isHidden = true
                self.startLoading()
                self.controlledView?.seekToTime(Int(self.progressSlider.value))
            }

            print("-------End")
            break
            
        case .cancelled:
            self.editing = false
            self.progressView.isHidden = true
            print("-------Cancelled")
            
            break
            
        case .failed:
            self.editing = false
            self.progressView.isHidden = true
            print("-------Failed")

            break
            
        default:
            print("-------default")

            break
        }
    }
    
    
    
    //MARK:----Observer
    

    func changeFrame(_ frame:CGRect){
        
    }
    
    func playButtonAction(_ playBtn : UIButton){
        self.isPlaying = !self.isPlaying
        self.controlledView?.playAction(self.isPlaying)
    }

    func sliderTouchUp(_ slider : UISlider){
        self.startLoading()
        self.controlledView?.seekToTime(Int(slider.value))
        editing = false
    }
    
    func sliderBeginTouch(_ slider : UISlider){
        editing = true
    }
    func sliderTouchCancel(_ slider : UISlider){
        editing = false
    }

    func changeScreenStatus(){
        self.controlledView?.changeScreenStatus()
    }
    
    func sliderValueChanged(_ slider : UISlider){
        self.timeUpdateDirect(Int64(slider.value))
    }
    
    
    
    /// 直接更新时间
    ///
    /// - parameter time: Int64
    fileprivate func timeUpdateDirect(_ time: Int64) {
        
        let currentTime = time
        self.progressSlider.value = Float(currentTime)
        let minutesElapsed = Float(currentTime)/60.0
        let secondsElapsed = fmod(Float(currentTime), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        self.startTimeLabel.text = timeElapsedString as String
    }
    
    
    func progerssViewTimeUpdate() {
        let change = self.progressSlider.value - startPanTime
        let changeStr = String.init(format: "%d秒", Int(change))
        let totalStr = String.init(format: "%@/%@", formatTime(Int(self.progressSlider.value)),formatTime(Int(self.progressSlider.maximumValue)))

        progressView.changedTimeLabel.text = changeStr
        progressView.totalTimeLabel.text = totalStr
        
    }
    
    //MARK:--------VideoStatusProtocol---------
    
    func timeUpdate(_ time: Int64) {
        guard editing == false else {
            return
        }
        self.timeUpdateDirect(time)
    }
    
    func startLoading() {
        self.isPlaying = false
        self.playButton.isHidden = true
        self.cancelFadeControlBar()
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    func endLoading() {
        if let totalTime = self.controlledView?.totalTime(){
            self.totalTimeLabel.text = self.formatTime(totalTime)
            self.progressSlider.maximumValue =  Float(totalTime)
//            KPerPanMove = Float(totalTime)/200.0
        }
        self.playButton.isHidden = false
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
        self.isPlaying = true
        self.show()
    }
    
    //MARK:-------------Util--------------
    func formatTime(_ time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }

}
