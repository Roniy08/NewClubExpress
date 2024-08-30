//
//  UIButton+SetText.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import UIKit

extension UIButton {
    func setTitleForAllStates(title: String) {
        UIView.performWithoutAnimation {
            self.setTitle(title, for: .normal)
            self.setTitle(title, for: .selected)
        }
    }
    
    func setTitleColourForAllStates(colour: UIColor) {
        UIView.performWithoutAnimation {
            self.setTitleColor(colour, for: .normal)
            self.setTitleColor(colour, for: .selected)
        }
    }
}
