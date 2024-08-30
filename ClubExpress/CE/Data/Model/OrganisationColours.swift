//
//  OrganisationColours.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 17/01/2019.
//  
//

import UIKit

enum statusBarStyle {
    case light
    case dark
}

class OrganisationColours {
    var primaryBgColour: UIColor = UIColor.mtBrandBlueLight
    var secondaryBgColour: UIColor = UIColor.mtBrandBlueDark
    var tintColour: UIColor = UIColor.white
    var statusBarStyle: statusBarStyle = .light
    var statusBarStyleFromSecondaryColour: statusBarStyle = .light
    var textColour: UIColor = UIColor.white
    var textColourFromSecondaryColour: UIColor = UIColor.white
    var ColourForToolbarBackground: UIColor = UIColor.clear
    var isPrimaryBgColourDark: Bool = true
    var isSecondaryBgColourDark: Bool = true
    
    func setColours(primaryBgColourString: String, secondaryBgColourString: String) {
        self.primaryBgColour = UIColor(hex: primaryBgColourString)
        self.secondaryBgColour = UIColor(hex: secondaryBgColourString)
        
        isPrimaryBgColourDark = self.primaryBgColour.isDarkColour()
        isSecondaryBgColourDark = self.secondaryBgColour.isDarkColour()
        
        self.textColour = isPrimaryBgColourDark ? UIColor.white : UIColor.mtMatteBlack
        self.textColourFromSecondaryColour = isSecondaryBgColourDark ? UIColor.white : UIColor.mtMatteBlack
        
        self.tintColour = isPrimaryBgColourDark ? UIColor.white : UIColor.mtMatteBlack
        self.statusBarStyle = isPrimaryBgColourDark ? .light : .dark
        self.statusBarStyleFromSecondaryColour = isSecondaryBgColourDark ? .light : .dark
    }
}
