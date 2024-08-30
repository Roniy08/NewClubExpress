//
//  CalendarEventsHeaderCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class CalendarEventsHeaderCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(dateString: String) {
        dateLabel.text = dateString
        
        dateLabel.textColor = UIColor.white
        dateLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 14)
        
        backgroundColor = UIColor(red: 158/255, green: 165/255, blue: 177/255, alpha: 1.0)
    }

}
