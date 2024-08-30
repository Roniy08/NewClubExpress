//
//  MenuIconView.swift
//  ClubExpress
//
//  Created by Joe Benton on 25/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class MenuIconView: UIView {
    
    var menuPressedCallback: () -> Void?
    var label: UILabel?
    
    init(count: Int, tintColour: UIColor, menuPressed: @escaping () -> Void) {
        self.menuPressedCallback = menuPressed
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        let formattedMenuCount = UserDefaults.standard.string(forKey: "UpdateCount")
        self.tintColor = tintColour
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenuNotificationLabelCount), name:Notification.Name.init("UpdateCount"), object: nil)
        
        setupView()
    }
    
    @objc func updateMenuNotificationLabelCount(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let count = userInfo["count"] as? Int {
                DispatchQueue.main.async {
                    UserDefaults.standard.set("\(count)", forKey: "UpdateCount")
                    self.formatMenuCount(count: count)
                    self.label!.layoutIfNeeded()
                    self.label!.setNeedsDisplay()
                }
               
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        let underlyingView = UIView()
        
        let menuImage = UIImage(named: "icSlideoutMenuNavigation")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(menuImage, for: .normal)
        button.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
        button.tintColor = self.tintColor
        var updateCount = UserDefaults.standard.string(forKey: "UpdateCount")
        
        var notificationCount = UserDefaults.standard.string(forKey: "UpdateCount")  ?? "0"
        self.label = InsetLabel()
        label!.textAlignment = .center
        label!.layer.masksToBounds = true
        label!.textColor = UIColor.white
        label!.font = UIFont.openSansSemiBoldFontOfSize(size: 10)
        label!.backgroundColor = UIColor.red
        label!.text = UserDefaults.standard.string(forKey: "UpdateCount") ?? "44"
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
        
        if Int(UserDefaults.standard.string(forKey: "UpdateCount") ?? "0") == 0 {
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
    
    @objc func menuButtonPressed(button: UIButton) {
        menuPressedCallback()
    }
    
    
    
    fileprivate func formatMenuCount(count: Int) -> String {
        if count == 0 {
            return ""
        }
        if count > 99 {
            return "99+"
        } else {
            var updateCount = UserDefaults.standard.string(forKey: "UpdateCount")
            return UserDefaults.standard.string(forKey: "UpdateCount") ?? "55"
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
