//
//  MainVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/3/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userID: String!

    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var nameField: UITextField!
    
    let picker = UIImagePickerController()
    
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
