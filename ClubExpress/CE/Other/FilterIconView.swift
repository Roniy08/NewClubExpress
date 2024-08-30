//
//  FilterIconView.swift
//  ClubExpress
//
//  Created by Joe Benton on 20/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit

class FilterIconView: UIView {
    
    var filtersApplied: Bool = false
    var filterPressedCallback: () -> Void?
    var button: UIButton?
    var indicator: UIView?
    var indicatorTopConstraint: NSLayoutConstraint?
    var indicatorRightConstraint: NSLayoutConstraint?
    
    init(filtersApplied: Bool, tintColour: UIColor, filterPressed: @escaping () -> Void) {
        self.filterPressedCallback = filterPressed
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        self.filtersApplied = filtersApplied

        self.tintColor = tintColour
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        let underlyingView = UIView()
        
        let filterImage = UIImage(named: "icFilterDirectory")?.withRenderingMode(.alwaysTemplate)
        self.button = UIButton(type: .system)
        button!.setImage(filterImage, for: .normal)
        button!.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        button!.tintColor = self.tintColor
        
        self.indicator = UIView()
        indicator!.layer.masksToBounds = true
        indicator!.backgroundColor = UIColor.red
        indicator!.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        indicator!.layer.shadowRadius = 4
        indicator!.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        indicator!.translatesAutoresizingMaskIntoConstraints = false
        button!.addSubview(indicator!)
        
        indicator!.heightAnchor.constraint(equalToConstant: 10).isActive = true
        indicator!.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
        indicator!.layer.cornerRadius = 5
        
        if filtersApplied == false {
            indicator!.isHidden = true
        }
        
        button!.translatesAutoresizingMaskIntoConstraints = false
        underlyingView.addSubview(button!)
        button!.constraintToSuperView(superView: underlyingView)
        
        let customView = CustomBarButtonWrapperView(underlyingView: underlyingView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(customView)
        customView.constraintToSuperView(superView: self)
    }
    
    @objc func filterButtonPressed(button: UIButton) {
        filterPressedCallback()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setIndicatorInsetsConstraints()
        
        if let indicator = self.indicator {
            if indicator.bounds.width > 0 && indicator.bounds.height > 0 {
                indicator.layer.shadowPath = CGPath(roundedRect: indicator.bounds, cornerWidth: 5, cornerHeight: 5, transform: nil)
            }
        }
    }
    
    fileprivate func setIndicatorInsetsConstraints() {
        guard let button = self.button else { return }
        guard let indicator = self.indicator else { return }
        
        let buttonImageWidth = button.imageView?.frame.size.width ?? 0
        let iconViewWidth = self.frame.size.width
        let rightInset = ((iconViewWidth - buttonImageWidth) / 2) - 2
        
        let buttonImageHeight = button.imageView?.frame.size.height ?? 0
        let iconViewHeight = self.frame.size.height
        let topInset = ((iconViewHeight - buttonImageHeight) / 2) - 4
        
        if let existingTopConstraint = self.indicatorTopConstraint {
            existingTopConstraint.isActive = false
        }
        indicatorTopConstraint = indicator.topAnchor.constraint(equalTo: button.topAnchor,constant: topInset)
        indicatorTopConstraint?.isActive = true
        
        if let existingRightConstraint = self.indicatorRightConstraint {
            existingRightConstraint.isActive = false
        }
        indicatorRightConstraint = indicator.trailingAnchor.constraint(equalTo: button.trailingAnchor,constant: -rightInset)
        indicatorRightConstraint?.isActive = true
    }
}
