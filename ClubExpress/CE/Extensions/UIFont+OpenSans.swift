//
//  UIFont+OpenSans.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/12/2018.
//  
//

import UIKit

extension UIFont {
    class func openSansFontOfSize(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "OpenSans", size: size) else {
            fatalError("Could not find OpenSans font")
        }
        return font
    }
    
    class func openSansSemiBoldFontOfSize(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "OpenSans-Semibold", size: size) else {
            fatalError("Could not find OpenSans-Semibold font")
        }
        return font
    }
    
    class func openSansBoldFontOfSize(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "OpenSans-Bold", size: size) else {
            fatalError("Could not find OpenSans-Bold font")
        }
        return font
    }
}
