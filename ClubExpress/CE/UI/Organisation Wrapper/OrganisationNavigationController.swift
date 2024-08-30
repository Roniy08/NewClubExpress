//
//  OrganisationNavigationController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class OrganisationNavigationController: UINavigationController {

    var organisationColours: OrganisationColours!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = organisationColours.primaryBgColour
        navigationBar.tintColor = organisationColours.tintColour
        navigationBar.barTintColor = organisationColours.primaryBgColour
        
        
        
        let attributes = [
            NSMutableAttributedString.Key.font: UIFont.openSansSemiBoldFontOfSize(size: 17),
            NSAttributedString.Key.foregroundColor: organisationColours.tintColour]
        navigationBar.titleTextAttributes = attributes
        
        //remove shadow line
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = organisationColours.primaryBgColour
            navBarAppearance.titleTextAttributes = attributes
            navBarAppearance.shadowImage = UIImage()
            navBarAppearance.shadowColor = .clear
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch organisationColours.statusBarStyle {
        case .light:
            return .lightContent
        case .dark:
            return .default
        }
    }
}
