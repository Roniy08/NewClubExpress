//
//  SplashInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

enum SplashError: Error {
    case sessionTokenError
    case savedOrganisationError
    case noOrganisationsInUpdate
    case savedOrganisationNotFound
    case noMenuEntriesInUpdate
    case noOrganisationID
    case unknownError
}

class SplashInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var directoryRepository: DirectoryRepository
    fileprivate var calendarRepository: CalendarRepository
    fileprivate var notificationsRepository: NotificationsRepository
    
    init(sessionRepository: SessionRepository, directoryRepository: DirectoryRepository, calendarRepository: CalendarRepository, notificationsRepository: NotificationsRepository) {
        self.sessionRepository = sessionRepository
        self.directoryRepository = directoryRepository
        self.calendarRepository = calendarRepository
        self.notificationsRepository = notificationsRepository
    }
    
    func getSessionState() -> Session? {
        return sessionRepository.getSession()
    }
    
    func checkForUpdatedNotificationsToken() -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(SplashError.sessionTokenError)
                return
            }
            
            notificationsRepository.checkForUpdatedNotificationsToken(sessionToken: sessionToken).done { (success) in
                seal.fulfill(success)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func removeLocalData() {
        //Remove local user data
        sessionRepository.clearUserData()
//        directoryRepository.clearAllAppliedFilters()
//        calendarRepository.clearCalendarData()
    }
    
    func getSelectedOrgID() -> String {
        guard let session = sessionRepository.getSession() else { return "" }
        guard let selectedOrganisation = session.selectedOrganisation else { return "" }
        if let orgID = selectedOrganisation.id {
            return orgID
        } else {
            return ""
        }
    }
}
