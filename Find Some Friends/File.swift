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
    private var _time: TimeInterval
    
    var uid: String {
        return _uid
    }
    
    var time: TimeInterval {
        return _time
    }
    
    init(uid: String, time: TimeInterval) {
        self._uid = uid
        self._time = time
    }
    
}
