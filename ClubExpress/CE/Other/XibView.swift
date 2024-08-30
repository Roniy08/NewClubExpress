//
//  XibView.swift
//  ClubExpress
//
//  Created by Joe Benton on 10/01/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class XibView: UIView {
    var view: UIView!
    var viewTopAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    //load view from xib and constraint to superview
    func xibSetup() {
        backgroundColor = UIColor.clear
        view = loadViewFromXib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        viewTopAnchor = view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        viewTopAnchor?.isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: 0).isActive = true
    }
}

extension UIView {
    func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
