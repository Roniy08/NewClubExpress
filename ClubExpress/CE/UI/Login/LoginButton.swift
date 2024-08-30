//
//  LoginButton.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import UIKit

class LoginButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 6
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
