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

class Main1VC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var collection: UICollectionView!
    
    var userID: String!
    var maleFemale: Int?
    
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
        ref.child("priority").observeSingleEvent(of: .value, with: { (snapshot) in
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
        cell.profileImg.image = currentUser.profilePic
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
        //temporary placeholder
        let alert = UIAlertController(title: "Coming soon!", message: "You will be able to boost your profile using credits. Each user will get 3 credits every day, but right now, profiles will be randomly shuffled", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
            self.users = []
            // Get user value
            for snap in snapshot.children.allObjects as! [FIRDataSnapshot]{
                let r1 = self.storage.child(snap.key)
                r1.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        let user = User(uid: snap.key, profilePic: UIImage(data: data!)!, time: snap.value as! TimeInterval)
                        
                        self.users.append(user)
                        //self.users.sort(by: {$0.time > $1.time})
                        self.users.shuffle()
                        self.collection.reloadData()
                    }
                })
                
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateCredits(mf: Int) {
        switch mf {
        case 0:
            base_ref.child("male").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let credits = snapshot.childSnapshot(forPath: "credits").value
                self.creditsLbl.text = "\(credits!) Credits"
            }) { (error) in
                print(error.localizedDescription)
            }
        case 1:
            base_ref.child("female").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let credits = snapshot.childSnapshot(forPath: "credits").value
                self.creditsLbl.text = "\(credits!) Credits"
            }) { (error) in
                print(error.localizedDescription)
            }
        default: break
        }
    }
    

}
