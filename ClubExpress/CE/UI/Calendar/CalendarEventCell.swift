//
//  CalendarEventCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class CalendarEventCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calendarNameLabel: UILabel!
    @IBOutlet weak var calendarColourImageView: UIImageView!
    
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
    
    func configure(event: CalendarEvent) {
        styleCell()
        
        if let title = event.title {
            titleLabel.text = title
        }
        
        let allDay = event.allDay ?? false
        
        let start_Date = (event.startDate ?? Date()) as Date
        let end_date = (event.endDate ?? Date()) as Date
        // date 1 compare with date 2 in calendat event type set 
        if allDay == true || end_date < start_Date || start_Date == end_date {
            timeLabel.text = "All day"
        } else {
            var timesArray = Array<String>()
            if let startTime = event.startTime {
                timesArray.append(startTime)
            }
            if let endTime = event.endTime {
                timesArray.append(endTime)
            }
            let timeString = timesArray.joined(separator: " - ")
            timeLabel.text = timeString
        }
        
        if let calendar = event.parentCalendar {
            if let calendarName = calendar.name {
                calendarNameLabel.text = calendarName
            }
            if let calendarColourCode = calendar.colourCode {
                let calendarColour = UIColor(hex: calendarColourCode)
                calendarNameLabel.textColor = calendarColour
                calendarColourImageView.backgroundColor = calendarColour
            }
        }
    }
    
    fileprivate func styleCell() {
        titleLabel.textColor = UIColor.mtMatteBlack
        titleLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 16)
        
        timeLabel.textColor = UIColor.mtMatteBlack
        timeLabel.font = UIFont.openSansFontOfSize(size: 14)
        
        calendarNameLabel.font = UIFont.openSansFontOfSize(size: 14)
        
        calendarColourImageView.layer.cornerRadius = 3
        calendarColourImageView.clipsToBounds = true
    }

}
