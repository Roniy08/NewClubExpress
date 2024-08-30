//
//  CalendarSettingsInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class CalendarSettingsInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var calendarRepository: CalendarRepository
    
    init(sessionRepository: SessionRepository, calendarRepository: CalendarRepository) {
        self.sessionRepository = sessionRepository
        self.calendarRepository = calendarRepository
    }
    
    func getStoredCalendars() -> Array<OrgCalendar> {
        return calendarRepository.getStoredCalendars()
    }
    
    func updateStoredCalendar(calendar: OrgCalendar) {
        calendarRepository.updateStoredCalendar(calendar: calendar)
    }
    
    func getOrganisationName() -> String {
        guard let session = sessionRepository.getSession() else { return "" }
        guard let selectedOrganisation = session.selectedOrganisation else { return "" }
        return selectedOrganisation.name ?? ""
    }
}
