//
//  BasketIconView.swift
//  ClubExpress
//
//  Created by Joe Benton on 13/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class BasketIconView: UIView {

    var countString: String = ""
    var basketPressedCallback: () -> Void?
    var label: UILabel?
    
    init(count: Int, tintColour: UIColor, basketPressed: @escaping () -> Void) {
        self.basketPressedCallback = basketPressed
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        let formattedBasketCount = formatBasketCount(count: count)
        self.countString = formattedBasketCount
        self.tintColor = tintColour

        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        let underlyingView = UIView()

        let basketImage = UIImage(named: "icShoppingCart")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(basketImage, for: .normal)
        button.addTarget(self, action: #selector(basketButtonPressed), for: .touchUpInside)
        button.tintColor = self.tintColor
        
        self.label = InsetLabel()
        label!.textAlignment = .center
        label!.layer.masksToBounds = true
        label!.textColor = UIColor.white
        label!.font = UIFont.openSansSemiBoldFontOfSize(size: 10)
        label!.backgroundColor = UIColor.red
        label!.text = countString
        label!.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        label!.layer.shadowRadius = 4
        label!.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        label!.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label!)
        label!.topAnchor.constraint(equalTo: button.topAnchor,constant: 5).isActive = true
        label!.trailingAnchor.constraint(equalTo: button.trailingAnchor,constant: -5).isActive = true
        label!.heightAnchor.constraint(equalToConstant: 16).isActive = true
        label!.widthAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        
        label!.layer.cornerRadius = 8
        
        if countString.count == 0 {
            label!.isHidden = true
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        underlyingView.addSubview(button)
        button.constraintToSuperView(superView: underlyingView)
        
        let customView = CustomBarButtonWrapperView(underlyingView: underlyingView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(customView)
        customView.constraintToSuperView(superView: self)
    }
    
    @objc func basketButtonPressed(button: UIButton) {
        basketPressedCallback()
    }
    
    fileprivate func formatBasketCount(count: Int) -> String {
        if count == 0 {
            return ""
        }
        if count > 99 {
            return "99+"
        } else {
            return "\(count)"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let label = self.label {
            if label.bounds.width > 0 && label.bounds.height > 0 {
                label.layer.shadowPath = CGPath(roundedRect: label.bounds, cornerWidth: 8, cornerHeight: 8, transform: nil)
            }
        }
    }
}
