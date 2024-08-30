//
//  EmptyPlaceholder.swift
//  ClubExpress
//
//  Created by Joe Benton on 16/01/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class EmptyPlaceholder: XibView {
    
    var title: String?
    var message: String?
    var topInsetBy: CGFloat = 0 {
        didSet {
            if topInsetBy != oldValue {
                updateTopInset()
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func xibSetup() {
        super.xibSetup()
        
        titleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 17)
        messageLabel.font = UIFont.openSansFontOfSize(size: 15)
        
        titleLabel.textColor = UIColor.mtMatteBlack
        messageLabel.textColor = UIColor(red: 143/255, green: 144/255, blue: 146/255, alpha: 1.0)
        
        updateText()
    }
    
    func updateText() {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    fileprivate func updateTopInset() {
        viewTopAnchor?.constant = topInsetBy
    }
}
