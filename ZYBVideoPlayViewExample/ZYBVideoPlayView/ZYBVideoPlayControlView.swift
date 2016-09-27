//
//  ZYBVideoPlayControlView.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 16/6/30.
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

class ZYBVideoPlayControlView: UIView {

    private let kVideoControlTopBarHeight : CGFloat = 44.0
    private let kVideoControlBottomBarHeight : CGFloat = 44.0
    private let kVideoControlPlayBtnWidth : CGFloat = 60.0
    private let kVideoControlTimeLabelWidth : CGFloat = 50.0
    private let kVideoControlTimeLabelFontSize : CGFloat = 10.0
    private let kVideoControlVideoNameLabelFontSize : CGFloat = 16.0
    private let kVideoControlAnimationTimeinterval = 0.4
    private let kVideoControlAutoHiddenTime = 3.0

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
    func hide(){
        if !isShowing {
            return;
        }
        
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
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ZYBVideoPlayControlView.hide), object: nil)
        self.performSelector(#selector(ZYBVideoPlayControlView.hide), withObject: nil, afterDelay: kVideoControlAutoHiddenTime)
    }
    func cancelFadeControlBar(){
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(ZYBVideoPlayControlView.hide), object: nil)
    }
    
    
    
    override init(frame: CGRect) {
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
        
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ZYBVideoPlayControlView.onTap(_:)))
        self.addGestureRecognizer(tapGesture)
    
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
    }
    
    func onTap(tap : UITapGestureRecognizer){
        if isShowing {
            self.hide()
        }else{
            self.show()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
