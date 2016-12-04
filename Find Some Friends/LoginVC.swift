//
//  LoginVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/3/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not the first launch")
        } else {
            
            print("First launch, displaying welcome message")
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

