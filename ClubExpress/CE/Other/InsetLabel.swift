//
//  InsetLabel.swift
//  ClubExpress
//
//  Created by Joe Benton on 13/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    let horizontalInset: CGFloat = 5
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
