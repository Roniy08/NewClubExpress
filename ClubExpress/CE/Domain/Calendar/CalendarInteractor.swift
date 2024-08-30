//
//  CalendarInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

enum CalendarError: Error {
    case sessionTokenError
    case noSelectedOrganisation
    case noCalendars
    case noEvents
    case unknownError
}

class CalendarInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var calendarRepository: CalendarRepository
    
    init(sessionRepository: SessionRepository, calendarRepository: CalendarRepository) {
        self.sessionRepository = sessionRepository
        self.calendarRepository = calendarRepository
    }
        
    //Get calendars
    func getCalendars() -> Promise<CalendarsModel> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(CalendarError.sessionTokenError)
                return
            }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(CalendarError.noSelectedOrganisation)
                return
            }
            
            calendarRepository.getCalendars(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    //Get events
    func getEvents(startTimestmap: Int, endTimestamp: Int) -> Promise<Array<CalendarEvent>> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(CalendarError.sessionTokenError)
                return
            }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(CalendarError.noSelectedOrganisation)
                return
            }
            
            //cancel pending events requests
            calendarRepository.cancelPendingEventsRequests()
            
            //get new events
            calendarRepository.getEvents(sessionToken: sessionToken, organisationID: organisationID, startTimestamp: startTimestmap, endTimestamp: endTimestamp, timezone: getTimezone()).done { response in
                seal.fulfill(response)
            }.catch(policy: .allErrors) { error in
                seal.reject(error)
            }
        }
    }
    
    func clearStoredCalendars() {
        calendarRepository.clearStoredCalendars()
    }
    
    func clearStoredEvents() {
        calendarRepository.clearStoredEvents()
    }

    func getStoredEventsForDay(date: Date) -> Array<CalendarEvent> {
        let allEvents = calendarRepository.getStoredEvents()

        let calendar = Calendar.current
        let selectedDayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let selectedDayYear = selectedDayComponents.year ?? 0
        let selectedDayMonth = selectedDayComponents.month ?? 0
        let selectedDayDay = selectedDayComponents.day ?? 0

        let selectedDayEvents = allEvents.filter { (event) -> Bool in
            if let startDate = event.startDate, let endDate = event.endDate {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone.mtTimeZone(identifier: getTimezone())
                let eventStartDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
                let eventStartYear = eventStartDateComponents.year ?? 0
                let eventStartMonth = eventStartDateComponents.month ?? 0
                let eventStartDay = eventStartDateComponents.day ?? 0
                
                let eventEndDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
                let eventEndYear = eventEndDateComponents.year ?? 0
                let eventEndMonth = eventEndDateComponents.month ?? 0
                let eventEndDay = eventEndDateComponents.day ?? 0
                
                //check if event exists on day
                if selectedDayYear >= eventStartYear && selectedDayYear <= eventEndYear {
                    if selectedDayMonth >= eventStartMonth && selectedDayMonth <= eventEndMonth {
                        if selectedDayDay >= eventStartDay && selectedDayDay <= eventEndDay {
                            return true
                        }
                    }
                }
            }
            return false
        }
        return selectedDayEvents
    }

    func getTimezone() -> String {
        guard let session = sessionRepository.getSession() else { fatalError("Session not found") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Selected organization not found") }

        let timezone = selectedOrganisation.timezone ?? ""
        return timezone
    }
}
