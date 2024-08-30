//
//  CalendarGridInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class CalendarGridInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var calendarRepository: CalendarRepository
    
    init(sessionRepository: SessionRepository, calendarRepository: CalendarRepository) {
        self.sessionRepository = sessionRepository
        self.calendarRepository = calendarRepository
    }
    
    func getEvents() -> Array<CalendarEvent> {
        return calendarRepository.getStoredEvents()
    }
    
    func getTimezone() -> String {
        guard let session = sessionRepository.getSession() else { fatalError("Session not found") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Selected organization not found") }
        
        let timezone = selectedOrganisation.timezone ?? ""
        return timezone
    }
}

