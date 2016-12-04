//
//  LoginVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/3/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not the first launch")
        } else {
            
            print("First launch, displaying welcome message")
            let aC = UIAlertController(title: "Welcome", message: "Welcome to FSF! Feel free to login/signup here. If you don't have an account, it will be created automatically. If you do, just sign in as usual. You will then be prompted to set a profile picture. Have fun! -John", preferredStyle: UIAlertControllerStyle.alert)
            aC.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
            present(aC, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    //success
                    
                } else {
                    //there's an error
                }
            }
            
        } else {
            //doesnt have both fields filled out
        }
    }
    


}

