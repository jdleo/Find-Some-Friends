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
    
    var userID: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Not the first launch")
            let alreadySetup = UserDefaults.standard.bool(forKey: "alreadySetup")
            if alreadySetup {
                performSegue(withIdentifier: "goToMain11", sender: nil)
            } else {
                print(alreadySetup)
            }
        } else {
            
            print("First launch, displaying welcome message")
            showAlert(alertTitle: "Welcome", msg: "Welcome to FSF! Feel free to login/signup here. If you don't have an account, it will be created automatically. If you do, just sign in as usual. You will then be prompted to set a profile picture. Have fun! -John", actionTitle: "Okay!")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
        }
        
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("some error, ill handle it later")
                } else {
                    self.userID = user?.uid
                    self.performSegue(withIdentifier: "goToMain", sender: nil)
                }
            })
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToMain") {
            let destination = segue.destination as? MainVC
            destination?.userID = userID
        } else if (segue.identifier == "goToMain11") {
            let destination = segue.destination as? Main1VC
            destination?.userID = userID
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            if password.characters.count >= 8 {
                //password is over 8 chars
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        //some error
                        if let code = FIRAuthErrorCode(rawValue: (error?._code)!) {
                            
                            switch code {
                            case .errorCodeUserDisabled:
                                //user is banned
                                self.showAlert(alertTitle: "Oh No!", msg: "You've been banned! Please contact the admin j@zaap.ws and let's get this resolved", actionTitle: "Okay :(")
                            case .errorCodeUserNotFound:
                                //user not found, create account here
                                FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                                    if error != nil {
                                        self.showAlert(alertTitle: "Oops", msg: (error?.localizedDescription)!, actionTitle: "Okay!")
                                    } else {
                                        UserDefaults.standard.set(email, forKey: "email")
                                        UserDefaults.standard.set(password, forKey: "password")
                                        self.userID = user?.uid
                                        self.performSegue(withIdentifier: "goToMain", sender: nil)
                                        
                                    }
                                }
                                
                            default:
                                //just show the localized desc. to the user
                                self.showAlert(alertTitle: "Oops", msg: (error?.localizedDescription)!, actionTitle: "Okay!")
                            }
                            
                        }
                        
                    } else {
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(password, forKey: "password")
                        self.userID = user?.uid
                        self.performSegue(withIdentifier: "goToMain", sender: nil)

                    }
                }
            } else {
                //password is under 8 chars
                showAlert(alertTitle: "Oops!", msg: "Password must be at least 8 characters", actionTitle: "Okay!")
            }
            
        }
    
    }
    
    func showAlert(alertTitle: String, msg: String, actionTitle: String) {
        let aC = UIAlertController(title: alertTitle, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        aC.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.cancel, handler: nil))
        present(aC, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    


}

