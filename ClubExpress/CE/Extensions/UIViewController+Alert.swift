//
//  UIViewController+Alert.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import UIKit

extension UIViewController {
    func showAlertPopup(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayBtn = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(okayBtn)
        
        present(alertVC, animated: true, completion: nil)
    }
}
