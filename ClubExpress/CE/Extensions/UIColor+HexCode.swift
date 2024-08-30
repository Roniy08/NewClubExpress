//
//  UIColor+HexCode.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 17/01/2019.
//  
//

import UIKit

extension UIColor {
    convenience init(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 3) {
            //double code for shortened colour codes - e.g. 000 becomes 000000
            cString = "\(cString)\(cString)"
        } else if ((cString.count) != 6) {
            print("colour code error: \(cString)")
            cString = "000000"
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
