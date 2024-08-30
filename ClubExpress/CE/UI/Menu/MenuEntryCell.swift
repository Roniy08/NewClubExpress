//
//  MenuEntryCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol MenuEntryCellDelegate: class {
    func didPressPage(menuEntry: NavigationEntry)
    func didPressDropdown(menuEntry: NavigationEntry)
}

class MenuEntryCell: UITableViewCell {

    fileprivate enum menuEntryType {
        case none
        case page
        case dropdown
        case both
    }
    
    fileprivate var menuEntry: NavigationEntry?
    weak var delegate: MenuEntryCellDelegate?
    fileprivate var isOpen = false
    var organisationColours: OrganisationColours!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dividerImageView: UIImageView!
    @IBOutlet weak var dropdownImageView: UIImageView!
    @IBOutlet weak var dropdownBtn: UIButton!
    @IBOutlet weak var pageBtn: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var titleLabelTrailingDropdown: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTrailingDivider: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTrailingEdge: NSLayoutConstraint!
    @IBOutlet weak var unreadCountLabel: UnreadIndicatorLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(menuEntry: NavigationEntry, selected: Bool, isOpen: Bool) {
        self.menuEntry = menuEntry
        self.isOpen = isOpen
        
        var entryType: menuEntryType = .none
        if let subEntries = menuEntry.entries, subEntries.count > 0 {
            if menuEntry.url != nil {
                entryType = .both
            } else {
                entryType = .dropdown
            }
        } else {
            entryType = .page
        }
        
        titleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
        titleLabel.text = menuEntry.label
        
        dividerImageView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        styleCellWithType(type: entryType)
        
        var normalBackgroundColour = UIColor.white
        if let level = menuEntry.level {
            if level == 0 {
                titleLabelLeadingConstraint.constant = 25
            } else if level == 1 {
                titleLabelLeadingConstraint.constant = 35
                normalBackgroundColour = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
            } else if level == 2 {
                titleLabelLeadingConstraint.constant = 45
                normalBackgroundColour = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
            }
        }
        
        if selected {
            backgroundColor = organisationColours.primaryBgColour.withAlphaComponent(0.14)
            titleLabel.textColor = organisationColours.isPrimaryBgColourDark ? organisationColours.primaryBgColour : UIColor.mtMatteBlack
        } else {
            backgroundColor = normalBackgroundColour
            titleLabel.textColor = UIColor.mtMatteBlack
        }
    }
    
    fileprivate func styleCellWithType(type: menuEntryType) {
        switch type {
        case .none, .page:
            dividerImageView.isHidden = true
            dropdownImageView.isHidden = true
            
            pageBtn.isHidden = false
            dropdownBtn.isHidden = true
            
            titleLabelTrailingDivider.priority = .defaultLow
            titleLabelTrailingDropdown.priority = .defaultLow
            titleLabelTrailingEdge.priority = .defaultHigh
        case .dropdown:
            dividerImageView.isHidden = true
            dropdownImageView.isHidden = false
            
            pageBtn.isHidden = true
            dropdownBtn.isHidden = false
            
            titleLabelTrailingDivider.priority = .defaultLow
            titleLabelTrailingDropdown.priority = .defaultHigh
            titleLabelTrailingEdge.priority = .defaultLow
            
            configureDropdownArrow()
        case .both:
            dividerImageView.isHidden = false
            dropdownImageView.isHidden = false
            // made changes on tap of menu's title also set menu expand on expandable titles.
            pageBtn.isHidden = false
            dropdownBtn.isHidden = false
            
            titleLabelTrailingDivider.priority = .defaultHigh
            titleLabelTrailingDropdown.priority = .defaultLow
            titleLabelTrailingEdge.priority = .defaultLow
            
            configureDropdownArrow()
        }
    }

    @IBAction func pageBtnPressed(_ sender: Any) {
        guard let menuEntry = self.menuEntry else { return }
        delegate?.didPressPage(menuEntry: menuEntry)
    }
    
    @IBAction func dropdownBtnPressed(_ sender: Any) {
        guard let menuEntry = self.menuEntry else { return }
        delegate?.didPressDropdown(menuEntry: menuEntry)
        
        twistDropdownArrow()
        isOpen = !isOpen
    }
    
    fileprivate func configureDropdownArrow() {
        var startAngle: Double = 0
        if self.isOpen {
            startAngle = 180
        }
        
        let zRotationKeyPath = "transform.rotation.z"
        let angleToAdd = Float(startAngle * Double.pi / 180)
        dropdownImageView.layer.setValue(angleToAdd, forKeyPath: zRotationKeyPath)
    }
    
    fileprivate func twistDropdownArrow() {
        let zRotationKeyPath = "transform.rotation.z"
        guard let currentAngleNumber = dropdownImageView.layer.value(forKeyPath: zRotationKeyPath) as? NSNumber else { return }
        let currentAngle = currentAngleNumber.floatValue
        var angleToAdd = Float(180 * Double.pi / 180)
        if isOpen {
            angleToAdd = -angleToAdd
        }
        dropdownImageView.layer.setValue(currentAngle + angleToAdd, forKeyPath: zRotationKeyPath)
        var rotateArrow: CABasicAnimation
        rotateArrow = CABasicAnimation(keyPath: zRotationKeyPath)
        rotateArrow.duration = 0.2
        rotateArrow.toValue = NSNumber(value: 0)
        rotateArrow.byValue = NSNumber(value: angleToAdd)
        rotateArrow.isAdditive = true
        dropdownImageView.layer.add(rotateArrow, forKey: "rotateArrow")
    }
    
    func toggleUnreadCount(count: Int) {
        if count > 0 {
            unreadCountLabel.isHidden = false
            unreadCountLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 12)
            unreadCountLabel.text = formatUnreadCount(count: count)
            unreadCountLabel.textColor = UIColor.white
            unreadCountLabel.backgroundColor = UIColor.red
            unreadCountLabel.layer.cornerRadius = 10.25
            unreadCountLabel.layer.masksToBounds = true
            
            
        } else {
            hideUnreadCount()
        }
    }
    
    func hideUnreadCount() {
        unreadCountLabel.isHidden = true
    }
    
    fileprivate func formatUnreadCount(count: Int) -> String {
        if count == 0 {
            return ""
        }
        if count > 99 {
            return "99+"
        } else {
            return "\(count)"
        }
    }
}
