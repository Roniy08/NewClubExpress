//
//  CalendarEventsEmptyCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 08/02/2019.
//  
//

import UIKit

class CalendarEventsEmptyCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont.openSansFontOfSize(size: 14)
        titleLabel.textColor = UIColor(red: 143/255, green: 144/255, blue: 146/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
