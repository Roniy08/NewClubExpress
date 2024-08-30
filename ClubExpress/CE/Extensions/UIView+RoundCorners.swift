//
//  UIView+RoundCorners.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat, rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
