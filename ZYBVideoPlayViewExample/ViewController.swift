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

    //play live video is the same as play video link
    @IBAction func playLiveVideo(sender: AnyObject) {
        let src = "http://livehls1-cnc.wasu.cn/ozzq/z.m3u8?UID=e5d8959965e50859886469f189129d1b&k=50c5cd3138e587c10965f3b66a4b2549&t=57f4529f&vid=17661&cid=9&version=MIPlayer_V1.4.2"
        playView.contentURL = NSURL.init(string: src)
        playView.videoName = "playing live video"
    }
    
    @IBAction func playVideoLink(sender: AnyObject) {
        let src = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"
        playView.contentURL = NSURL.init(string: src)
        playView.videoName = "playing video link"
    }
    
    @IBAction func playVideoFile(sender: AnyObject) {
        let path = NSBundle.mainBundle().pathForResource("test", ofType: "mp4")
        playView.contentURL = NSURL.init(fileURLWithPath: path!)
        playView.videoName = "playing video file"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

