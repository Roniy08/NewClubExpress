//
//  CalendarSettingsLocalSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol CalendarSettingsLocalSource {
    func getCalendars() -> Array<OrgCalendar>
    func saveCalendars(calendars: Array<OrgCalendar>)
    func clearCalendars()
    func updateCalendar(calendar: OrgCalendar)
}

class CalendarSettingsLocalSourceImpl: CalendarSettingsLocalSource {
    var calendars = Array<OrgCalendar>()
    
    func getCalendars() -> Array<OrgCalendar> {
        return calendars
    }
    
    func saveCalendars(calendars: Array<OrgCalendar>) {
        self.calendars = calendars
    }
    
    func clearCalendars() {
        self.calendars = []
    }
    
    func updateCalendar(calendar: OrgCalendar) {
        guard let id = calendar.id else { return }

        let calendarIndex = calendars.firstIndex { (existingCalendar) -> Bool in
            return existingCalendar.id == id
        }
        if let calendarIndex = calendarIndex {
            //Update enabled
            calendars[calendarIndex].enabled = calendar.enabled
        }
    }
}
