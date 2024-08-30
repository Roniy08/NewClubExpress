//
//  NotifOrgSwitcherInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 26/03/2019.
//  
//

import Foundation
import PromiseKit

enum NotifOrgSwitcherError: Error {
    case sessionTokenError
    case unknownError
    case errorMessage(message: String)
}

class NotifOrgSwitcherInteractor {
    fileprivate var sessionRepository: SessionRepository
    
    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func getSessionToken() -> String? {
        if let session = sessionRepository.getSession(), let sessionToken = session.sessionToken {
            return sessionToken
        }
        return nil
    }

    func clearSelectedOrganisation() {
        sessionRepository.clearSelectedOrganisationData()
    }
}
