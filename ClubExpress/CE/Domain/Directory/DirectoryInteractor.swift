//
//  DirectoryInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit


enum DirectoryError: Error {
    case sessionTokenError
    case noSelectedOrganisation
    case noDirectoryEntries
    case unknownError
}

class DirectoryInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var directoryRepository: DirectoryRepository
    
    init(sessionRepository: SessionRepository, directoryRepository: DirectoryRepository) {
        self.sessionRepository = sessionRepository
        self.directoryRepository = directoryRepository
    }
    
    func getDirectoryEntries() -> Promise<DirectoryResponse> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(DirectoryError.sessionTokenError)
                return
            }

            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(DirectoryError.noSelectedOrganisation)
                return
            }

            directoryRepository.getDirectory(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getAppliedFilters() -> Array<DirectoryAppliedFilter> {
        return directoryRepository.getAppliedFilters()
    }
    
    func clearAppliedFilters() {
        directoryRepository.clearAllAppliedFilters()
    }
    
    func getBaseUrl() -> String {
        guard let session = sessionRepository.getSession() else {
            return ""
        }
        
        guard let organisation = session.selectedOrganisation else {
            return ""
        }
        
        return organisation.baseUrl ?? ""
    }
}
