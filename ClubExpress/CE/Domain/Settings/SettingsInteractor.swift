//
//  SettingsInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/02/2019.
//  
//

import Foundation
import PromiseKit

enum SettingsError: Error {
    case sessionTokenError
    case unknownError
    case errorMessage(message: String)
}

class SettingsInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var notificationsRepository: NotificationsRepository
    
    init(sessionRepository: SessionRepository, notificationsRepository: NotificationsRepository) {
        self.sessionRepository = sessionRepository
        self.notificationsRepository = notificationsRepository
    }
    
    func getSession() -> Session {
        guard let session = sessionRepository.getSession() else { fatalError("Session could not be found") }
        return session
    }
    
    func toggleNotifications() -> Promise<BaseResponse> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(SettingsError.sessionTokenError)
                return
            }
            
            notificationsRepository.toggleNotifications(sessionToken: sessionToken).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getNotificationsEnabledState() -> Bool {
        return notificationsRepository.notificationsEnabledState()
    }
}
