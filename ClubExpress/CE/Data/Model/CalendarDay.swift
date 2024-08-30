//
//  CalendarDay.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

enum calendayDayType {
    case empty
    case normal
}

class CalendarDay {
    var cellType: calendayDayType?
    var date: Date?
    var events: Array<CalendarEvent>?
    var selected: Bool = false
    var today: Bool = false
    
    init(cellType: calendayDayType?, date: Date?, events: Array<CalendarEvent>?) {
        self.cellType = cellType
        self.date = date
        self.events = events
    }
}
