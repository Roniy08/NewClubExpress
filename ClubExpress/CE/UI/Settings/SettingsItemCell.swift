//
//  SettingsItemCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/02/2019.
//  
//

import UIKit

protocol SettingsItemCellDelegate: class {
    func toggleSwitched(item: SettingsItem, enabled: Bool)
}

class SettingsItemCell: UITableViewCell {

    var organisationColours: OrganisationColours!
    var item: SettingsItem?
    weak var delegate: SettingsItemCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryStackView: UIStackView!
    @IBOutlet weak var arrowAccessoryWrapper: UIView!
    @IBOutlet weak var toggleAccessoryWrapper: UIView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var iconWrapper: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(item: SettingsItem) {
        self.item = item
        
        titleLabel.font = UIFont.openSansFontOfSize(size: 15)
        
        toggleSwitch.onTintColor = organisationColours.primaryBgColour
        
        iconWrapper.isHidden = true
        iconImageView.tintColor = organisationColours.primaryBgColour
        
        if let itemType = item.type {
            switch itemType {
            case .toggleNotifications(let enabled):
                toggleSwitch.setOn(enabled, animated: false)
            case .toggleAuth(let enabled):
                toggleSwitch.setOn(enabled, animated: false)
            case .changeOrganisation:
                iconWrapper.isHidden = false
                iconImageView.image = UIImage(named: "icSwapOrganisation")?.withRenderingMode(.alwaysTemplate)
            default: break
            }
        }
        
        if let accessoryType = item.accessoryType {
            switch accessoryType {
            case .nothing:
                arrowAccessoryWrapper.isHidden = true
                toggleAccessoryWrapper.isHidden = true
            case .arrow:
                arrowAccessoryWrapper.isHidden = false
                toggleAccessoryWrapper.isHidden = true
            case .toggleSwitch:
                arrowAccessoryWrapper.isHidden = true
                toggleAccessoryWrapper.isHidden = false
            }
        }
        
        if let textStyle = item.textStyle {
            switch textStyle {
            case .normal:
                titleLabel.textColor = UIColor.mtMatteBlack
            case .destructive:
                titleLabel.textColor = UIColor(red: 191/255, green: 46/255, blue: 44/255, alpha: 1.0)
            }
        }
        
        if let title = item.title {
            titleLabel.text = title
        }
    }
    
    @IBAction func toggleSwitchChanged(_ sender: Any) {
        guard let item = self.item else { return }
        delegate?.toggleSwitched(item: item, enabled: toggleSwitch.isOn)
    }
}
