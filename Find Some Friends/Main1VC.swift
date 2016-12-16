//
//  Main1VC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/3/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import Foundation
import NVActivityIndicatorView

class Main1VC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var collection: UICollectionView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    var userID: String!
    var maleFemale = 9
    
    var myCredits: Int?
    
    let reuse = "UserCell"
    
    let ref = FIRDatabase.database().reference().child("priority")
    let base_ref = FIRDatabase.database().reference().child("users")
    let storage = FIRStorage.storage().reference(forURL: "gs://findsomefriends-65c41.appspot.com/profilepics/")
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        collection.delegate = self
        collection.dataSource = self
        
        segmentControl.addTarget(self, action: #selector(Main1VC.segmentedControlValueChanged), for:.valueChanged)
        segmentControl.addTarget(self, action: #selector(Main1VC.segmentedControlValueChanged), for:.touchUpInside)
        
        //find out if male or female, then load credits lbl
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // Check if current user is male or female to save time digging thru db
            if snapshot.childSnapshot(forPath: "male").hasChild(self.userID) {
                self.maleFemale = 0
                self.updateCredits(mf: 0)
                
            } else if snapshot.childSnapshot(forPath: "female").hasChild(self.userID) {
                self.maleFemale = 1
                self.updateCredits(mf: 1)
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        loadUsers(gender: "all")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToSettings") {
            let destination = segue.destination as? SettingsVC
            destination?.userID = userID
        } else if (segue.identifier == "goToProfile") {
            let controller = (segue.destination as! ProfileVC)
            let item = (sender as! NSIndexPath).item //we know that sender is an NSIndexPath here.
            let uid = users[item].uid
            controller.theirID = uid
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuse, for: indexPath as IndexPath) as! UserCell
        let currentUser = users[indexPath.item]
        let r1 = self.storage.child(currentUser.uid)
        if let img = self.imageCache.object(forKey: currentUser.uid as NSString) {
            cell.profileImg.image = img
            } else {
            r1.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    cell.profileImg.image = UIImage(data: data!)!
                    self.imageCache.setObject(UIImage(data:data!)!, forKey: currentUser.uid as NSString)
                    }
            })
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.item]
        print(selectedUser.uid)
        performSegue(withIdentifier: "goToProfile", sender: indexPath)
    }
    @IBAction func settingsBtn(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {}
    
    @IBAction func boostBtn(_ sender: AnyObject) {
        //adjust credits, then update priority timestamp
        // theres a chance it doesnt have a value tho (for some reason) so we'll do if-let
        if let creds = self.myCredits {
            if creds >= 1 {
                self.myCredits = (creds-1)
                //check if male/female, then boost, also get current time for timestamp
                let currentTime = NSDate().timeIntervalSince1970
                switch maleFemale {
                case 0:
                    boost(gender: "male", uid: userID, currentTime: currentTime)
                    updateCredits(mf: 0)
                    showAlert(ttl: "Success!", msg: "Your profile has been boosted. You now have \(self.myCredits!) credits!", btn: "Thanks, okay!")
                case 1:
                    boost(gender: "female", uid: userID, currentTime: currentTime)
                    updateCredits(mf: 0)
                    showAlert(ttl: "Success!", msg: "Your profile has been boosted. You now have \(self.myCredits!) credits!", btn: "Thanks, okay!")
                default: break
                }
                
                
            } else {
                showAlert(ttl: "Oops!", msg: "You're all out of credits!", btn: "Okay :(")
            }
        }
    }
    
    func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            //all
            print("load all")
            loadUsers(gender: "all")
            
        } else if segment.selectedSegmentIndex == 1 {
            //male
            print("load male")
            loadUsers(gender: "male")
            
        } else if segment.selectedSegmentIndex == 2 {
            //female
            loadUsers(gender: "female")
            
        }
        
    }
    
    func loadUsers(gender: String) {
        
        ref.child(gender).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.users = []
            
            self.showSpinner()
            for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    let user = User(uid: snap.key, time: snap.value! as! TimeInterval)
                    self.users.append(user)
            }
            
           self.users.shuffle()
            self.collection.reloadData()
}) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateCredits(mf: Int) {
        switch mf {
        case 0:
            base_ref.child("male").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let credits = snapshot.childSnapshot(forPath: "credits").value
                self.myCredits = credits as! Int?
                self.creditsLbl.text = "\(credits!) Credits"
            }) { (error) in
                print(error.localizedDescription)
            }
        case 1:
            base_ref.child("female").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let credits = snapshot.childSnapshot(forPath: "credits").value
                self.myCredits = credits as! Int?
                self.creditsLbl.text = "\(credits!) Credits"
            }) { (error) in
                print(error.localizedDescription)
            }
        default: break
        }
    }
    
    func showSpinner() {
        let size = CGSize(width: 70, height:70)
        
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType(rawValue: 30)!)
        perform(#selector(delayedStopActivity),
                with: nil,
                afterDelay: 3)
    }
    
    func delayedStopActivity() {
        stopAnimating()
    }
    
    func showAlert(ttl: String, msg: String, btn: String) {
        let aC = UIAlertController(title: ttl, message: msg, preferredStyle: .alert)
        aC.addAction(UIAlertAction(title: btn, style: .cancel, handler: nil))
        present(aC, animated: true, completion: nil)
    }
    
    func boost(gender: String, uid: String, currentTime: TimeInterval) {
        //read credits first
        base_ref.child(gender).child(uid).child("credits").observeSingleEvent(of: .value, with: { (snapshot) in
            let creditsInDb = snapshot.value as! Int
            let newCredits = (creditsInDb-1)
            //then set new credit count
            self.base_ref.child(gender).child(uid).child("credits").setValue(newCredits)
        
            //then update priority timestamp
            self.ref.child(gender).child(uid).setValue(currentTime)
            
            
        }) { (error) in
            self.showAlert(ttl: "Oops", msg: error.localizedDescription, btn: "Okay :(")
        }
        
    }
    

}
