//
//  RoundedProfilePic.swift
//  FSF
//
//  Created by John Leonardo on 9/8/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit

class RoundedProfilePic: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //layer.borderWidth = 0.5
        layer.masksToBounds = false
        //layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
