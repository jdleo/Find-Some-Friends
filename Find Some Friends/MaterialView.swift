//
//  MaterialUIView.swift
//  Zaap
//
//  Created by John Leonardo on 9/8/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit

private var materialKey = false

extension UIView {
    
    @IBInspectable var materialDesign: Bool {
        
        get {
            return materialKey
        } set {
            materialKey = newValue
            
            // if I set materialdesign to true in interface builder, inherit these view props. thx google
            if materialKey {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 7.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowRadius = 3.0
                self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                self.layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
            } else {
                self.layer.cornerRadius = 0
                self.layer.shadowOpacity = 0
                self.layer.shadowRadius = 0
                self.layer.shadowColor = nil
            }
            
        }
        
        
        
    }
}
