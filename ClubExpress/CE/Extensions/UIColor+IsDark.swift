//
//  UIColor+IsDark.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

extension UIColor {
    func isDarkColour() -> Bool {
        //turn to rgb colour to get components
        let rgbColour = self.cgColor
        guard let rgbColours = rgbColour.components else { return false }
        guard rgbColours.count == 4 else { return false }
        
        let red = rgbColours[0]
        let green = rgbColours[1]
        let blue = rgbColours[2]
        
        //Counting the perceptive luminance
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return lum < 0.50 ? true : false
    }
}
