//
//  CalendarEventContentInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class CalendarEventContentInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var calendarRepository: CalendarRepository
    
    init(sessionRepository: SessionRepository, calendarRepository: CalendarRepository) {
        self.sessionRepository = sessionRepository
        self.calendarRepository = calendarRepository
    }
    
    func getEventDetail(entryID: String) -> Promise<CalendarEventDetail> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(CalendarError.sessionTokenError)
                return
            }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(CalendarError.noSelectedOrganisation)
                return
            }
            
            calendarRepository.getEventDetail(sessionToken: sessionToken, organisationID: organisationID, entryID: entryID).done { response in
                let eventDetail = CalendarEventDetail(eventDescription: response.eventDescription, upcomingDates: response.upcomingDates, ads: response.ads)
                seal.fulfill(eventDetail)
            }.catch(policy: .allErrors) { error in
                seal.reject(error)
            }
        }
    }
    
    func getTimezone() -> String {
        guard let session = sessionRepository.getSession() else { fatalError("Session not found") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Selected organization not found") }
        
        let timezone = selectedOrganisation.timezone ?? ""
        return timezone
    }
}
