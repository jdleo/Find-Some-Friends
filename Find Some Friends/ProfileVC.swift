//
//  ProfileVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/5/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileVC: UIViewController {
    
    var theirID: String!
    let storage = FIRStorage.storage().reference(forURL: "gs://findsomefriends-65c41.appspot.com/profilepics/")
    let ref = FIRDatabase.database().reference()
    let reportRef = FIRDatabase.database().reference().child("reports")
    
    @IBOutlet weak var twitterLbl: UILabel!
    @IBOutlet weak var instagramLbl: UILabel!
    @IBOutlet weak var snapchatLbl: UILabel!
    @IBOutlet weak var kikLbl: UILabel!
    @IBOutlet weak var wechatLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var profileImg: RoundedProfilePic!
    
    @IBOutlet weak var bgView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        self.profileImg.layer.borderWidth = 1
        self.profileImg.layer.borderColor = UIColor(colorLiteralRed: 28/255, green: 185/255, blue: 207/255, alpha: 1).cgColor
        
        let r1 = storage.child(theirID)
        r1.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self.profileImg.image = UIImage(data: data!)
            }
        })
        
        ref.child("priority").observeSingleEvent(of: .value, with: { (snapshot) in
            // Check if current user is male or female to save time digging thru db
            if snapshot.childSnapshot(forPath: "male").hasChild(self.theirID) {
                self.updateFields(mf: 0)
                
            } else if snapshot.childSnapshot(forPath: "female").hasChild(self.theirID) {
                self.updateFields(mf: 1)
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    func updateFields(mf: Int) {
        switch mf {
        case 0:
            ref.child("users").child("male").child(theirID).observeSingleEvent(of: .value, with: { (snapshot) in
                let socials = snapshot.childSnapshot(forPath: "socials").value as! NSDictionary
                self.wechatLbl.text = "\(socials.value(forKey: "wechat")!)"
                self.twitterLbl.text = "\(socials.value(forKey: "twitter")!)"
                self.snapchatLbl.text = "\(socials.value(forKey: "snapchat")!)"
                self.lineLbl.text = "\(socials.value(forKey: "line")!)"
                self.instagramLbl.text = "\(socials.value(forKey: "instagram")!)"
                self.kikLbl.text = "\(socials.value(forKey: "kik")!)"
                
            }) { (error) in
                print(error.localizedDescription)
            }
        case 1:
            ref.child("users").child("female").child(theirID).observeSingleEvent(of: .value, with: { (snapshot) in
                let socials = snapshot.childSnapshot(forPath: "socials").value as! NSDictionary
                self.wechatLbl.text = "\(socials.value(forKey: "wechat")!)"
                self.twitterLbl.text = "\(socials.value(forKey: "twitter")!)"
                self.snapchatLbl.text = "\(socials.value(forKey: "snapchat")!)"
                self.lineLbl.text = "\(socials.value(forKey: "line")!)"
                self.instagramLbl.text = "\(socials.value(forKey: "instagram")!)"
                self.kikLbl.text = "\(socials.value(forKey: "kik")!)"
            }) { (error) in
                print(error.localizedDescription)
            }
        default: break
            
        }
    }
    
    @IBAction func backBtn(_ sender: AnyObject) {
        performSegue(withIdentifier: "unwindToMain1", sender: nil)
    }
    
    @IBAction func reportBtn(_ sender: AnyObject) {
        let actionSheet: UIAlertController = UIAlertController(title: "Report this user", message: "Select a reason for reporting, and I'll review the issue :)", preferredStyle: .actionSheet)
        
        let caseNumber = UUID().uuidString
        
        //Create and add the "Cancel" action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheet.addAction(cancelAction)
        
        //Create and add "Yes" action
        let action1: UIAlertAction = UIAlertAction(title: "Inappropriate picture", style: .default) { action -> Void in
            self.uploadReport(id: caseNumber, reason: "nudes", uid: self.theirID)
            self.showAlert(ttl: "Done!", msg: "I'll look into it, thanks!")
        }
        
        
        let action2: UIAlertAction = UIAlertAction(title: "Harassment", style: .default) { action -> Void in
            self.uploadReport(id: caseNumber, reason: "harassment", uid: self.theirID)
            self.showAlert(ttl: "Done!", msg: "Your report has been sent. I'll look into this. If any more problems come up, please email me at j@zaap.ws and use Case #\(caseNumber) for reference")
        }
        
        let action3: UIAlertAction = UIAlertAction(title: "Other...", style: .default) { action -> Void in
            self.uploadReport(id: caseNumber, reason: "other", uid: self.theirID)
            self.showAlert(ttl: "Need more info!", msg: "Please shoot me an email at j@zaap.ws and we will get this resolved. Case #\(caseNumber) (Please use this for reference in email)")
        }
        
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlert(ttl: String, msg: String) {
        let aC = UIAlertController(title: ttl, message: msg, preferredStyle: .alert)
        aC.addAction(UIAlertAction(title: "Okay!", style: .cancel, handler: nil))
        present(aC, animated: true, completion: nil)
    }
    
    func uploadReport(id: String, reason: String, uid: String) {
        let data = ["reason": reason, "uid": uid]
        reportRef.child(id).updateChildValues(data)
    }
    
    


}
