//
//  ViewController.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 16/6/30.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let playView = VideoPlayView.init(frame: CGRect(x:0 , y: 0 , width: UIScreen.main.bounds.width , height:  UIScreen.main.bounds.width*0.6))

    override func viewDidLoad() {
        super.viewDidLoad()
        //playView.autoStart = false
        self.view.addSubview(playView)

    }

    //play live video is the same as play video link
    @IBAction func playLiveVideo(_ sender: AnyObject) {
        let src = "http://livehls2-cnc.wasu.cn/dzty/z.m3u8?UID=9bfb6a99cb2f25c73010428e8d85a723&k=850ca934c48102b124de09d62d15ddd6&t=584fb76e&vid=1509878&cid=9&version=MIPlayer_V1.4.2"
        playView.playUrl(src, type: .online)
        playView.title = "playing live video"
    }
    
    @IBAction func playVideoLink(_ sender: AnyObject) {
        let src = "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"

        playView.playUrl(src, type: .online)
        playView.title = "playing live link"
    }
    
    @IBAction func playVideoFile(_ sender: AnyObject) {
        if let path = Bundle.main.path(forResource: "test", ofType: "mp4"){
            playView.playUrl(path, type: .local)
            playView.title = "playing video file"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

