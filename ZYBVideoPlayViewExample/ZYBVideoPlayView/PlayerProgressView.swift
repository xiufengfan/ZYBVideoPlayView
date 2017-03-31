//
//  PlayerProgressView.swift
//  VideoPlayer
//
//  Created by ylmf on 2016/12/2.
//  Copyright © 2016年 ylmf. All rights reserved.
//

import UIKit

class PlayerProgressView: UIView {

    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var changedTimeLabel: UILabel!
    
    
    var isFastForwarding = true{
        didSet{
            if isFastForwarding{
                statusImage.image = UIImage.init(named: "fastForward")
            }else{
                statusImage.image = UIImage.init(named: "faseRewind")
            }
        }
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.backgroundColor = UIColor.init(white: 0.2, alpha: 0.8)
        self.isUserInteractionEnabled = false
        
        self.statusImage.contentMode = UIViewContentMode.scaleAspectFit
        
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
