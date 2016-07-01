//
//  ViewController.swift
//  ZYBVideoPlayViewExample
//
//  Created by ylmf on 16/6/30.
//  Copyright © 2016年 ZYB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let playView = ZYBVideoPlayView.init(frame: CGRect(x:0 , y: 0 , width: UIScreen.mainScreen().bounds.width , height:  UIScreen.mainScreen().bounds.width*0.6))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(playView)

        
        


        
        
    }

    @IBAction func playRemoteVideo(sender: AnyObject) {
        let src = "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
        playView.contentURL = NSURL.init(string: src)
        playView.videoName = "Use ZYBVideoPlayView playing Remote video"
    }
    
    @IBAction func playLocalVideo(sender: AnyObject) {
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "mp4")
        playView.contentURL = NSURL.init(fileURLWithPath: path!)
        playView.videoName = "Use ZYBVideoPlayView playing local video"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

