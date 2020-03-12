//
//  PostDetails.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/12/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit

class PostDetails: UIView {

    @IBOutlet var contentView: UIView!
   let kCONTENT_XIB_NAME = "PostDetails"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

}
