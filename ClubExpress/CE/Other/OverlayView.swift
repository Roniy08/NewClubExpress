//
//  OverlayView.swift
//  ClubExpress
//
//  Created by Joe Benton on 10/01/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class OverlayView: XibView {
    
    var message: String? {
        didSet {
            loadingLabel.text = message
        }
    }
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func xibSetup() {
        super.xibSetup()
        
        loadingLabel.font = UIFont.openSansFontOfSize(size: 15)
    }
}
