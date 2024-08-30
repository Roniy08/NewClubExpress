//
//  UIView+ConstraintToSuperView.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 10/01/2019.
//  
//

import UIKit


extension UIView {
    func constraintToSuperView(superView: UIView) {
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: superView.topAnchor,constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor,constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor,constant: 0).isActive = true
    }
}
