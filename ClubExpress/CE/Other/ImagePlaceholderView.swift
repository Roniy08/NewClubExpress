//
//  ImagePlaceholderView.swift
//  ClubExpress
//
//  Created by Joe Benton on 20/12/2018.
//  Copyright © 2018 Zeta. All rights reserved.
//

import UIKit
import Kingfisher

class ImagePlaceholderView: UIView, Placeholder {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    }
    
}
