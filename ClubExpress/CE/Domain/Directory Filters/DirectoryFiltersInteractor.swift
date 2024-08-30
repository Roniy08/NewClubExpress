//
//  DirectoryFiltersInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit


enum DirectoryFiltersError: Error {
    case sessionTokenError
    case noSelectedOrganisation
    case noFilters
    case unknownError
}

class DirectoryFiltersInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var directoryRepository: DirectoryRepository
    
    init(sessionRepository: SessionRepository, directoryRepository: DirectoryRepository) {
        self.sessionRepository = sessionRepository
        self.directoryRepository = directoryRepository
    }
    
    func getDirectoryFilters() -> Promise<Array<DirectoryFilter>> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(DirectoryError.sessionTokenError)
                return
            }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(DirectoryError.noSelectedOrganisation)
                return
            }
            
            directoryRepository.getDirectoryFilters(sessionToken: sessionToken, organisationID: organisationID).done { response in
                if let filters = response.filters {
                    seal.fulfill(filters)
                } else {
                    seal.reject(DirectoryFiltersError.noFilters)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getAppliedFilters() -> Array<DirectoryAppliedFilter> {
        return directoryRepository.getAppliedFilters()
    }
    
    func saveAppliedFilters(appliedFilters: Array<DirectoryAppliedFilter>) {
        directoryRepository.saveAppliedFilters(appliedFilters: appliedFilters)
    }
    
    func clearAllAppliedFilters() {
        directoryRepository.clearAllAppliedFilters()
    }
    
    func hasCloseFiltersConfirmPopupShown() -> Bool {
        return sessionRepository.hasCloseFiltersConfirmPopupShown()
    }
    
    func setShownCloseFiltersConfirmPopup() {
        sessionRepository.setShownCloseFiltersConfirmPopup()
    }
}
