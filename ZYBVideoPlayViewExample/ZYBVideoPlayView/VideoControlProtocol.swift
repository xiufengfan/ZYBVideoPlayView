//
//  VideoControlProtocol.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 2016/12/2.
//  Copyright © 2016年 ZYB. All rights reserved.
//
import UIKit

typealias ZYBResultBlock = (AnyObject?,NSError?)->Void

protocol VideoControlProtocol {
    
    func startDragProgressSlider(progress : UISlider)
    
    /// 停止拖拽进度条
    ///
    /// - parameter progress: UISlider
    func endDragProgressSlider(progress : UISlider)
    
    
    /// 进度条值变化
    ///
    /// - parameter progress: UISlider
    func progressSliderValueChanged(progress : UISlider)
    
    
    /// 播放事件
    func playAction(play:Bool)
    
    /// 进度变化
    ///
    /// - parameter time: 目的进度
    func seekToTime(time : Int)
    
    /// 下一集按钮被按下
    func nextAction()

    /// 视频总时间
    ///
    /// - returns: Int
    func totalTime()->Int
    
    
    /// 屏幕大小改变
    func changeScreenStatus()
}


protocol VideoStatusProtocol {
    
    /// 播放时间更新
    ///
    /// - parameter time: 当前时间
    func timeUpdate(time : Int64)
    
    
    /// 开始缓冲
    func startLoading()
    
    
    /// 缓冲结束
    func endLoading()
}
