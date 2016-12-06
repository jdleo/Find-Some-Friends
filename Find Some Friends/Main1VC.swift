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
    
    let reuse = "UserCell"
    
    let ref = FIRDatabase.database().reference().child("priority")
    let storage = FIRStorage.storage().reference(forURL: "gs://findsomefriends-65c41.appspot.com/profilepics/")
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        collection.delegate = self
        collection.dataSource = self
        
        ref.child("all").observeSingleEvent(of: .value, with: { (snapshot) in
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
    

}
