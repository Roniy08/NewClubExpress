//
//  CalendarEventsLocalSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

protocol CalendarEventsLocalSource {
    func getEvents() -> Array<CalendarEvent>
    func saveEvents(events: Array<CalendarEvent>)
    func clearEvents()
}

class CalendarEventsLocalSourceImpl: CalendarEventsLocalSource {
    var events = Array<CalendarEvent>()
    
    func getEvents() -> Array<CalendarEvent> {
        return events
    }
    
    func saveEvents(events: Array<CalendarEvent>) {
        self.events = events
    }
    
    func clearEvents() {
        self.events = []
    }
}
