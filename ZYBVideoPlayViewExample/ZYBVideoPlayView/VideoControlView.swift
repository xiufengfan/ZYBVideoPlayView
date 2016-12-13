//
//  VideoControlView.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 2016/12/2.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit

extension UIImage{
    class func localImageWithName(name:String)->UIImage?{
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "png"){
            return UIImage.init(contentsOfFile: path)
        }
        return nil
    }
}

class VideoControlView: UIView ,VideoStatusProtocol{

    var controlledView : VideoControlProtocol?
    
    //
    private let kVideoControlTopBarHeight : CGFloat = 44.0
    private let kVideoControlBottomBarHeight : CGFloat = 44.0
    private let kVideoControlPlayBtnWidth : CGFloat = 60.0
    private let kVideoControlTimeLabelWidth : CGFloat = 50.0
    private let kVideoControlTimeLabelFontSize : CGFloat = 10.0
    private let kVideoControlVideoNameLabelFontSize : CGFloat = 16.0
    private let kVideoControlAnimationTimeinterval = 0.4
    private let kVideoControlAutoHiddenTime = 3.0
    private let kPanDistance : CGFloat = 100.0
    private let KPerPanMove  : Float = 1.0

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
    
    private var panIsVertical = true
    private var startPanTime : Float = 0

    var isPlaying = false{
        didSet{
            var name : String
            if isPlaying {
                name = "btn_pause"
            }else{
                name = "btn_play"
                
            }
            playButton.setBackgroundImage(UIImage.localImageWithName(name), forState: UIControlState.Normal)
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
        UIView.animateWithDuration(kVideoControlAnimationTimeinterval, animations: { [weak self] in
            self?.topBar.alpha = 0.0
            self?.bottomBar.alpha = 0.0
            self?.playButton.alpha = 0.0
        }) { [weak self] (res) in
            self?.isShowing = false
        }
    }
    
    func show(){
        if isShowing {
            return;
        }
        
        UIView.animateWithDuration(kVideoControlAnimationTimeinterval, animations: { [weak self] in
            self?.topBar.alpha = 1.0
            self?.bottomBar.alpha = 1.0
            self?.playButton.alpha = 1.0
        }) { [weak self] (res) in
            self?.isShowing = true
            self?.fadeControlBar()
        }
    }
    func fadeControlBar(){
        if !self.isShowing {
            return;
        }
        
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(VideoControlView.hide), object: nil)
        self.performSelector(#selector(VideoControlView.hide), withObject: nil, afterDelay: kVideoControlAutoHiddenTime)
    }
    func cancelFadeControlBar(){
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(VideoControlView.hide), object: nil)
    }
    
    
    
     override init(frame: CGRect) {
        
        pan = UIPanGestureRecognizer()

        topBar = UIView()
        topBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        bottomBar = UIView()
        bottomBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        playButton = UIButton.init(type: UIButtonType.Custom)
        playButton.setBackgroundImage(UIImage.localImageWithName("btn_play"), forState: UIControlState.Normal)
        
        fullScreenButton = UIButton.init(type: UIButtonType.Custom)
        fullScreenButton.setBackgroundImage(UIImage.localImageWithName("full_screen"), forState: UIControlState.Normal)
        fullScreenButton.frame = CGRect(x: 0,y: 0,width: kVideoControlBottomBarHeight,height: kVideoControlBottomBarHeight)
        
        progressSlider = UISlider()
        progressSlider.continuous = true
        startTimeLabel = UILabel()
        startTimeLabel.font = UIFont.systemFontOfSize(kVideoControlTimeLabelFontSize)
        startTimeLabel.textColor = UIColor.whiteColor()
        startTimeLabel.textAlignment = NSTextAlignment.Center
        
        totalTimeLabel = UILabel()
        totalTimeLabel.font = UIFont.systemFontOfSize(kVideoControlTimeLabelFontSize)
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.textAlignment = NSTextAlignment.Center
        
        videoNameLabel = UILabel()
        videoNameLabel.font = UIFont.systemFontOfSize(kVideoControlVideoNameLabelFontSize)
        videoNameLabel.textColor = UIColor.whiteColor()
        
        backButton = UIButton.init(type: UIButtonType.Custom)
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        
        progressView = NSBundle.mainBundle().loadNibNamed("PlayerProgressView", owner: nil, options: nil)![0] as! PlayerProgressView
        progressView.frame = CGRectMake(0, 0, 140, 100)
        progressView.hidden = true
        
        
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
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderBeginTouch(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderTouchCancel(_:)), forControlEvents: UIControlEvents.TouchCancel)
        self.progressSlider.addTarget(self, action: #selector(VideoControlView.sliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.fullScreenButton.addTarget(self, action: #selector(VideoControlView.changeScreenStatus), forControlEvents: UIControlEvents.TouchUpInside)
        self.playButton.addTarget(self, action: #selector(VideoControlView.playButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topBar.frame = CGRect(x : CGRectGetMinX(self.bounds), y : CGRectGetMinY(self.bounds), width:  CGRectGetMaxX(self.bounds), height : kVideoControlTopBarHeight);
        self.videoNameLabel.frame = CGRectMake(10, 0, self.topBar.frame.size.width, self.topBar.frame.size.height);
        self.backButton.frame = CGRectMake(0, 0, kVideoControlTopBarHeight, kVideoControlTopBarHeight);
        
        self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - kVideoControlBottomBarHeight, CGRectGetMaxX(self.bounds), kVideoControlBottomBarHeight);
        
        self.playButton.frame = CGRectMake( self.frame.size.width/2-kVideoControlPlayBtnWidth/2, self.frame.size.height/2-kVideoControlPlayBtnWidth/2 , kVideoControlPlayBtnWidth,kVideoControlPlayBtnWidth);
        
        self.fullScreenButton.frame = CGRectMake(CGRectGetMaxX(self.bottomBar.bounds) - self.fullScreenButton.bounds.width, self.bottomBar.bounds.height/2 - self.fullScreenButton.bounds.height/2, kVideoControlBottomBarHeight, kVideoControlBottomBarHeight);
        
        self.progressSlider.frame = CGRectMake(kVideoControlTimeLabelWidth, CGRectGetMaxY(self.bottomBar.bounds)/2 - CGRectGetMaxY(self.progressSlider.bounds)/2, CGRectGetMaxX(self.bounds) - kVideoControlTimeLabelWidth*2  - CGRectGetMaxX(self.fullScreenButton.bounds), CGRectGetMaxY(self.progressSlider.bounds));
        
        self.startTimeLabel.frame = CGRectMake(0, 0, kVideoControlTimeLabelWidth, CGRectGetHeight(self.bottomBar.frame));
        
        self.totalTimeLabel.frame = CGRectMake(CGRectGetMinX(self.fullScreenButton.frame)-kVideoControlTimeLabelWidth, CGRectGetMinY(self.startTimeLabel.frame), kVideoControlTimeLabelWidth,  CGRectGetHeight(self.bottomBar.frame));
        self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        self.progressView.frame = CGRectMake(0, 0, 140, 100)
        self.progressView.center = self.center

    }
    
    func onTap(tap : UITapGestureRecognizer){
        if isShowing {
            self.hideDirect()
        }else{
            self.show()
        }
    }
    
    /// 滑动手势
    ///
    /// - parameter ges: UIPanGestureRecognizer
    func panAction(ges : UIPanGestureRecognizer){
        let ve = ges.velocityInView(self)
        
        switch ges.state {
            
        case .Began:
            panIsVertical = abs(ve.x) < abs(ve.y)
            startPanTime = self.progressSlider.value
            
        case .Changed:
            guard abs(ve.x)>kPanDistance || abs(ve.y) > kPanDistance else {
                return
            }
            if panIsVertical {
                if (abs(ve.y) > kPanDistance) {
                    //左侧 亮度
                    if ges.locationInView(self).x<200 {
                        if (ve.y > kPanDistance) {
                            UIScreen.mainScreen().brightness -= 0.01;
                        }
                        if (ve.y < -kPanDistance){
                            UIScreen.mainScreen().brightness += 0.01;
                        }
                    }
                    
                    //右侧,音量
                    if (ges.locationInView(self).x > CGRectGetWidth(self.frame)-200) {
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
                        self.progressView.hidden = false
                        self.progressSlider.value += KPerPanMove
                        sliderValueChanged(self.progressSlider)
                        self.progressView.isFastForwarding = true
                        progerssViewTimeUpdate()
                        return
                    }
                    
                    //左滑
                    if ve.x < -kPanDistance {
                        //                    print("--------左滑")
                        self.progressView.hidden = false
                        self.progressSlider.value -= KPerPanMove
                        sliderValueChanged(self.progressSlider)
                        self.progressView.isFastForwarding = false
                        progerssViewTimeUpdate()
                        return
                    }
                }
            }
            break
            
        case .Ended:
            self.editing = false
            if panIsVertical == false{
                self.progressView.hidden = true
                self.startLoading()
                self.controlledView?.seekToTime(Int(self.progressSlider.value))
            }

            print("-------End")
            break
            
        case .Cancelled:
            self.editing = false
            self.progressView.hidden = true
            print("-------Cancelled")
            
            break
            
        case .Failed:
            self.editing = false
            self.progressView.hidden = true
            print("-------Failed")

            break
            
        default:
            print("-------default")

            break
        }
    }
    
    
    
    //MARK:----Observer
    

    func changeFrame(frame:CGRect){
        
    }
    
    func playButtonAction(playBtn : UIButton){
        self.isPlaying = !self.isPlaying
        self.controlledView?.playAction(self.isPlaying)
    }

    func sliderTouchUp(slider : UISlider){
        self.startLoading()
        self.controlledView?.seekToTime(Int(slider.value))
        editing = false
    }
    
    func sliderBeginTouch(slider : UISlider){
        editing = true
    }
    func sliderTouchCancel(slider : UISlider){
        editing = false
    }

    func changeScreenStatus(){
        self.controlledView?.changeScreenStatus()
    }
    
    func sliderValueChanged(slider : UISlider){
        self.timeUpdateDirect(Int64(slider.value))
    }
    
    
    
    /// 直接更新时间
    ///
    /// - parameter time: Int64
    private func timeUpdateDirect(time: Int64) {
        
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
    
    func timeUpdate(time: Int64) {
        guard editing == false else {
            return
        }
        self.timeUpdateDirect(time)
    }
    
    func startLoading() {
        self.isPlaying = false
        self.playButton.hidden = true
        self.cancelFadeControlBar()
        self.indicatorView.hidden = false
        self.indicatorView.startAnimating()
    }
    
    func endLoading() {
        if let totalTime = self.controlledView?.totalTime(){
            self.totalTimeLabel.text = self.formatTime(totalTime)
            self.progressSlider.maximumValue =  Float(totalTime)
//            KPerPanMove = Float(totalTime)/200.0
        }
        self.playButton.hidden = false
        self.indicatorView.hidden = true
        self.indicatorView.stopAnimating()
        self.isPlaying = true
        self.show()
    }
    
    //MARK:-------------Util--------------
    func formatTime(time : Int) -> String{
        let minutesElapsed = Float(time)/60.0
        let secondsElapsed = fmod(Float(time), 60.0)
        let timeElapsedString = NSString.init(format: "%02.0f:%02.0f", minutesElapsed,secondsElapsed)
        return timeElapsedString as String
    }

}
