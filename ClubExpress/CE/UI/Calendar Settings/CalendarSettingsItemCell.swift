//
//  CalendarSettingsItemCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol CalendarSettingsItemCellDelegate: class {
    func toggleSwitched(calendar: OrgCalendar, enabled: Bool)
    func subscribeBtnPressed(calendar: OrgCalendar)
}

class CalendarSettingsItemCell: UITableViewCell {

    var organisationColours: OrganisationColours!
    weak var calendar: OrgCalendar?
    weak var delegate: CalendarSettingsItemCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var toggleBtn: UISwitch!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(calendar: OrgCalendar) {
        self.calendar = calendar
        
        nameLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        if let colourCode = calendar.colourCode {
            let calendarColour = UIColor.init(hex: colourCode)
            nameLabel.textColor = calendarColour
        } else {
            nameLabel.textColor = UIColor.mtMatteBlack
        }
        
        let enabled = calendar.enabled ?? true
        toggleBtn.setOn(enabled, animated: false)
        
        nameLabel.text = calendar.name
        
        toggleBtn.onTintColor = organisationColours.primaryBgColour
        
        toggleLoadingIndicator(show: false)
        
        subscribeBtn.setTitleColourForAllStates(colour: UIColor.mtMatteBlack)
        subscribeBtn.layer.cornerRadius = 4
        subscribeBtn.clipsToBounds = true
        subscribeBtn.titleLabel?.font = UIFont.openSansFontOfSize(size: 14)
        subscribeBtn.tintColor = UIColor.mtMatteBlack
        
        if calendar.subscribed == true {
            subscribeBtn.setTitleForAllStates(title: "Synced to device calendar")
            subscribeBtn.isEnabled = false
            subscribeBtn.alpha = 0.5
            subscribeBtn.backgroundColor = UIColor.clear
            
            subscribeBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 0)
            subscribeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        } else {
            subscribeBtn.setTitleForAllStates(title: "Sync to device calendar")
            subscribeBtn.isEnabled = true
            subscribeBtn.alpha = 1
            subscribeBtn.backgroundColor = organisationColours.primaryBgColour.withAlphaComponent(0.1)
            
            subscribeBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 10)
            subscribeBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        }
        
    }

    @IBAction func subsscribeBtnPressed(_ sender: Any) {
        guard let calendar = self.calendar else { return }
        delegate?.subscribeBtnPressed(calendar: calendar)
        
        toggleLoadingIndicator(show: true)
    }
    
    @IBAction func toggleSwitched(_ sender: Any) {
        guard let calendar = self.calendar else { return }
        delegate?.toggleSwitched(calendar: calendar, enabled: toggleBtn.isOn)
    }
    
    fileprivate func toggleLoadingIndicator(show: Bool) {
        switch show {
        case true:
            loadingIndicator.startAnimating()
            subscribeBtn.isHidden = true
        case false:
            loadingIndicator.stopAnimating()
            subscribeBtn.isHidden = false
        }
    }
}
