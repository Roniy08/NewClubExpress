//
//  CalendarGridDayCell.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

class CalendarGridDayCell: UICollectionViewCell {
    
    var organisationColours: OrganisationColours!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dotsStackView: UIStackView!
    
    func configure(day: CalendarDay) {
        guard let type = day.cellType else { return }
        
        if type == .normal {
            guard let date = day.date else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"
            let dayString = dateFormatter.string(from: date)
            
            dateLabel.isHidden = false
            dateLabel.text = dayString
            dateLabel.font = UIFont.openSansSemiBoldFontOfSize(size: 17)
            dateLabel.layer.cornerRadius = dateLabel.frame.size.width / 2
            dateLabel.clipsToBounds = true
            
            if day.selected {
                dateLabel.backgroundColor = organisationColours.primaryBgColour
                dateLabel.textColor = organisationColours.textColour
            } else if day.today {
                dateLabel.backgroundColor = organisationColours.primaryBgColour.withAlphaComponent(0.15)
                dateLabel.textColor = UIColor.mtMatteBlack
            } else {
                dateLabel.backgroundColor = UIColor.clear
                dateLabel.textColor = UIColor.mtMatteBlack
            }
            
            dotsStackView.isHidden = false
            resetStackView()
            if let events = day.events {
                addEventDotsToStackView(events: events)
            }
        } else if type == .empty {
            dateLabel.text = ""
            dateLabel.isHidden = true
            dotsStackView.isHidden = true
            resetStackView()
        }
    }
    
    fileprivate func resetStackView() {
        for dot in dotsStackView.arrangedSubviews {
            dot.removeFromSuperview()
        }
    }
    
    fileprivate func addEventDotsToStackView(events: Array<CalendarEvent>) {
        let eventColours: Array<String> = events.compactMap { (event) -> String? in
            guard let calendar = event.parentCalendar else { return nil }
            guard let colourCode = calendar.colourCode else { return nil }
            return colourCode
        }
        let uniqueEventColours = Array(Set(eventColours))
        
        let maxVisibleDots = 4
        let moreThanMaxDots = uniqueEventColours.count > maxVisibleDots ? true : false
        let dotsToShow = moreThanMaxDots ? Array(uniqueEventColours[0..<(maxVisibleDots - 1)]) : uniqueEventColours
        
        for dotToShow in dotsToShow {
            let colour = UIColor(hex: dotToShow)
            let dotImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            dotImageView.layer.cornerRadius = 3
            dotImageView.clipsToBounds = true
            dotImageView.backgroundColor = colour
            dotImageView.widthAnchor.constraint(equalToConstant: 6).isActive = true
            dotImageView.heightAnchor.constraint(equalToConstant: 6).isActive = true
            
            dotsStackView.addArrangedSubview(dotImageView)
        }
        
        if moreThanMaxDots {
            let plusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            plusImageView.image = UIImage(named: "icMoreEventsSingleDay")
            plusImageView.layer.cornerRadius = 3
            plusImageView.widthAnchor.constraint(equalToConstant: 6).isActive = true
            plusImageView.heightAnchor.constraint(equalToConstant: 6).isActive = true
            
            dotsStackView.addArrangedSubview(plusImageView)
        }
    }
}
