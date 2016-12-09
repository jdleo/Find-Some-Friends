//
//  MainVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/3/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Foundation

class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userID: String!

    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var nameField: UITextField!
    
    let picker = UIImagePickerController()
    
    var ref: FIRDatabaseReference!
    let storage = FIRStorage.storage().reference(forURL: "gs://findsomefriends-65c41.appspot.com/profilepics/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alreadySetup = UserDefaults.standard.bool(forKey: "alreadySetup")
        
        if alreadySetup {
            performSegue(withIdentifier: "goToMain1", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePic.contentMode = .scaleAspectFill
            profilePic.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToMain1") {
            let destination = segue.destination as? Main1VC
            destination?.userID = userID
        }
    }

    @IBAction func saveBtn(_ sender: AnyObject) {
        if let name = nameField.text, nameField.text != "" {
            //store name, profile pic, gender in firebase
            let id = self.userID
            switch segment.selectedSegmentIndex {
            case 0:
                //male
                let data = ["name":name, "gender":"male", "likes": 0, "credits": 0, "socials" : ["snapchat": "none", "kik": "none", "wechat": "none", "line": "none", "twitter": "none", "instagram": "none"]] as [String : Any]
                ref = FIRDatabase.database().reference()
                let date = NSDate().timeIntervalSince1970
                ref.child("users").child("male").child(id!).updateChildValues(data)
                ref.child("priority").child("male").child(id!).setValue(date)
                ref.child("priority").child("all").child(id!).setValue(date)
                let r1 = storage.child(id!)
                let imgData: NSData = UIImageJPEGRepresentation(profilePic.image!, 0.2)! as NSData
                let uploadTask = r1.put(imgData as Data, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        UserDefaults.standard.set(true, forKey: "alreadySetup")
                        self.performSegue(withIdentifier: "goToMain1", sender: nil)
                    }
                }
                
            case 1:
                //female
                let data = ["name":name, "gender":"male", "likes": 0, "credits": 0, "socials" : ["snapchat": "none", "kik": "none", "wechat": "none", "line": "none", "twitter": "none", "instagram": "none"]] as [String : Any]
                ref = FIRDatabase.database().reference()
                let date = NSDate().timeIntervalSince1970
                ref.child("users").child("female").child(id!).updateChildValues(data)
                ref.child("priority").child("female").child(id!).setValue(date)
                ref.child("priority").child("all").child(id!).setValue(date)
                let r1 = storage.child(id!)
                let imgData: NSData = UIImageJPEGRepresentation(profilePic.image!, 0.2)! as NSData
                let uploadTask = r1.put(imgData as Data, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        UserDefaults.standard.set(true, forKey: "alreadySetup")
                        self.performSegue(withIdentifier: "goToMain1", sender: nil)
                    }
                }
            default: break
                
            }
            
            
        } else {
            //didnt set a name
            let aC = UIAlertController(title: "Oops", message: "You need to set a name", preferredStyle: UIAlertControllerStyle.alert)
            aC.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(aC, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func changeBtn(_ sender: AnyObject) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}
