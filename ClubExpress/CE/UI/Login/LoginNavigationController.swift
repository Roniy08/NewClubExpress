//
//  LoginNavigationController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class LoginNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.mtBrightWhite
        navigationBar.barTintColor = UIColor.mtBrightWhite

        let attributes = [
            NSMutableAttributedString.Key.font: UIFont.openSansSemiBoldFontOfSize(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.mtBrightWhite]
        navigationBar.titleTextAttributes = attributes
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
