//
//  File.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/4/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//
import Foundation
import UIKit

class User {
    private var _uid: String
    private var _profilePic: UIImage
    private var _time: TimeInterval
    
    var uid: String {
        return _uid
    }
    
    var profilePic: UIImage {
        return _profilePic
    }
    
    var time: TimeInterval {
        return _time
    }
    
    init(uid: String, profilePic: UIImage, time: TimeInterval) {
        self._uid = uid
        self._profilePic = profilePic
        self._time = time
    }
    
}
