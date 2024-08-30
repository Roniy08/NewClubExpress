//
//  CustomBarButtonWrapperView.swift
//  ClubExpress
//
//  Created by Joe Benton on 13/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class CustomBarButtonWrapperView: UIView {

    let minimumSize: CGSize = CGSize(width: 44.0, height: 44.0)
    let underlyingView: UIView
    init(underlyingView: UIView) {
        self.underlyingView = underlyingView
        super.init(frame: underlyingView.bounds)
        
        underlyingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underlyingView)
        
        NSLayoutConstraint.activate([
            underlyingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlyingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlyingView.topAnchor.constraint(equalTo: topAnchor),
            underlyingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        let heightConstraint = NSLayoutConstraint(item: underlyingView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: minimumSize.height)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        
        let widthConstraint = NSLayoutConstraint(item: underlyingView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: minimumSize.width)
        widthConstraint.priority = UILayoutPriority(rawValue: 999)
        
        self.addConstraints([widthConstraint, heightConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
