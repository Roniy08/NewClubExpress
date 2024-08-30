//
//  LoginTextField.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import UIKit

class LoginTextField: UITextField {

    fileprivate let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        layer.cornerRadius = 6
//        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 3, height: 4)
//        layer.shadowRadius = 6
//        layer.shadowOpacity = 0.4
//        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        if #available(iOS 13.0, *) {
            if let placeholder = placeholder {
                attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.4)])
            }
        }
    }
    
}
