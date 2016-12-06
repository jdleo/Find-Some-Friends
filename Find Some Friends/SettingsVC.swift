//
//  SettingsVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/5/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SettingsVC: UIViewController {
    
    var userID: String!
    var maleOrFemale: Int?
    
    let ref = FIRDatabase.database().reference()

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var snapchatField: UITextField!
    @IBOutlet weak var kikField: UITextField!
    @IBOutlet weak var wechatField: UITextField!
    @IBOutlet weak var twitterField: UITextField!
    @IBOutlet weak var instagramField: UITextField!
    @IBOutlet weak var lineField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)

        // Do any additional setup after loading the view.
        ref.child("priority").observeSingleEvent(of: .value, with: { (snapshot) in
            // Check if current user is male or female to save time digging thru db
            if snapshot.childSnapshot(forPath: "male").hasChild(self.userID) {
                print("\(self.userID) is male")
                self.maleOrFemale = 0
                
            } else if snapshot.childSnapshot(forPath: "female").hasChild(self.userID) {
                self.maleOrFemale = 1
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        if let mf = maleOrFemale {
            updateFields(mf: mf)
        }
    }
    
    func updateFields(mf: Int) {
        switch mf {
        case 0:
            ref.child("users").child("male").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Check if current user is male or female to save time digging thru db
                print(snapshot)
                
                }) { (error) in
                print(error.localizedDescription)
            }
        case 1:
            ref.child("users").child("female").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Check if current user is male or female to save time digging thru db
                print(snapshot)
                
            }) { (error) in
                print(error.localizedDescription)
            }
        default: break
            
        }
    }

}
