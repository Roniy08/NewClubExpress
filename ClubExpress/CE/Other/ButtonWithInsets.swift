//
//  ButtonWithInsets.swift
//  ClubExpress
//
//  Created by Joe Benton on 23/01/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class ButtonWithInsets: UIButton {

    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right + imageEdgeInsets.left + imageEdgeInsets.right
        let adjustedHeight = titleLabel!.intrinsicContentSize.height + contentEdgeInsets.top + contentEdgeInsets.bottom
        
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel!.preferredMaxLayoutWidth = titleLabel!.frame.width
    }
}
