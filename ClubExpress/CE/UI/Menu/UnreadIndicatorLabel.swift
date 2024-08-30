//
//  UnreadIndicatorLabel.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 25/03/2019.
//  
//

import UIKit

class UnreadIndicatorLabel: UILabel {
    
    let horizontalInset: CGFloat = 6
    let verticalInset: CGFloat = 2
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: horizontalInset + size.width + horizontalInset, height: verticalInset + size.height + verticalInset)
    }
}
