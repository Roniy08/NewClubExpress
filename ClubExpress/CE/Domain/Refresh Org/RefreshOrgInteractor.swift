//
//  RefreshOrgInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 26/03/2019.
//  
//

import Foundation
import PromiseKit

enum RefreshOrgInteractorError: Error {
    case sessionTokenError
    case savedOrganisationError
    case noOrganisationsInUpdate
    case savedOrganisationNotFound
    case noMenuEntriesInUpdate
    case noOrganisationID
    case unknownError
}

class RefreshOrgInteractor {
    fileprivate var organisationsRepository: OrganisationsRepository
    fileprivate var sessionRepository: SessionRepository
    
    init(organisationsRepository: OrganisationsRepository, sessionRepository: SessionRepository) {
        self.organisationsRepository = organisationsRepository
        self.sessionRepository = sessionRepository
    }
    
    func refreshOrganisationDetails(organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            let refreshOrganisationPromise = refreshOrganisation(toOrganisationID: organisationID)
            let refreshUserInfoPromise = refreshUserInfo(toOrganisationID: organisationID)
            let refreshNavigationPromise = refreshNavigationMenu(toOrganisationID: organisationID)
            
            //wait for all three to finish
            when(fulfilled: refreshOrganisationPromise, refreshUserInfoPromise, refreshNavigationPromise).done { refreshUserInfoResponse, refreshOrganisationResponse, refreshNavigationResponse in
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func refreshOrganisation(toOrganisationID organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(RefreshOrgInteractorError.sessionTokenError)
                return
            }
            
            organisationsRepository.getOrganisations(sessionToken: sessionToken).done { [weak self] organisationsResponse in
                guard let weakSelf = self else { return }
                
                let organisations = organisationsResponse.orgs
                if organisations.count > 0 {
                    let hasMultipleOrganisations = organisations.count == 1 ? false : true
                    weakSelf.sessionRepository.setHasMultipleOrganisations(hasMultipleOrganisations: hasMultipleOrganisations)
                    
                    let newOrganisation = organisations.filter({ (organisation) -> Bool in
                        return organisation.id == organisationID
                    }).first
                    
                    if let newOrganisation = newOrganisation {
                        weakSelf.sessionRepository.setSelectedOrganisation(organisation: newOrganisation)
                        seal.fulfill(true)
                    } else {
                        seal.reject(RefreshOrgInteractorError.savedOrganisationNotFound)
                    }
                } else {
                    seal.reject(RefreshOrgInteractorError.noOrganisationsInUpdate)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func refreshUserInfo(toOrganisationID organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(RefreshOrgInteractorError.sessionTokenError)
                return
            }
            
            organisationsRepository.getUserInfo(sessionToken: sessionToken, organisationID: organisationID).done { [weak self] response in
                guard let weakSelf = self else { return }
                let refreshedUserInfo = UserInfo(email: response.email, firstName: response.firstName, lastName: response.lastName, avatarUrl: response.avatarUrl, initialCartCount: response.initialCartCount, ablyAPIKey: response.ablyAPIKey, ablyChannel: response.ablyChannel, unreadOrgNotifications: response.unreadOrgNotifications, orgUnreadCounts: response.orgUnreadCounts,end_points: response.end_points, mtkAdmin: response.mtkAdmin)
                weakSelf.sessionRepository.setUserInfo(userInfo: refreshedUserInfo)
                
                seal.fulfill(true)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    func refreshNavigationMenu(toOrganisationID organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(RefreshOrgInteractorError.sessionTokenError)
                return
            }
            
            organisationsRepository.getNavigationMenu(sessionToken: sessionToken, organisationID: organisationID).done { [weak self] response in
                guard let weakSelf = self else { return }
                if let navigationMenuEntries = response.menuEntries, let settingsMenuEntries = response.settingsEntries {
                    weakSelf.sessionRepository.setNavigationMenu(entries: navigationMenuEntries)
                    weakSelf.sessionRepository.setSettingsMenu(entries: settingsMenuEntries)
                    seal.fulfill(true)
                } else {
                    seal.reject(RefreshOrgInteractorError.noMenuEntriesInUpdate)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
