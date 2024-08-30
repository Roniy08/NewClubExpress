//
//  OrganisationsInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

enum OrganisationsError: Error {
    case sessionTokenError
    case noSelectedOrganisation
    case unknownError
    case errorMessage(message: String)
    case noOrganisations
    case noNavigationMenuEntries
}

class OrganisationsInteractor {
    fileprivate var organisationsRepository: OrganisationsRepository
    var sessionRepository: SessionRepository
    fileprivate var notificationsRepository: NotificationsRepository
    fileprivate var loginRepository: LoginRepository
    weak var viewOrgs: OrganisationsView?
    
    init(organisationsRepository: OrganisationsRepository, sessionRepository: SessionRepository, notificationsRepository: NotificationsRepository, loginRepository: LoginRepository) {
        self.organisationsRepository = organisationsRepository
        self.sessionRepository = sessionRepository
        self.notificationsRepository = notificationsRepository
        self.loginRepository = loginRepository
    }
    
    func getOrganisations() -> Promise<Array<Organisation>> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(OrganisationsError.sessionTokenError)
                return
            }
            
            organisationsRepository.getOrganisations(sessionToken: sessionToken).done { [weak self] response in
                guard let weakSelf = self else { return }
                let organisations = response.orgs
                var unreadCount = Int((response.key ?? "0") as String) ?? 0
                if(response.key != "0") {
                    UIApplication.shared.applicationIconBadgeNumber = unreadCount
                }
                
                if organisations.count == 0 {
                    seal.reject(OrganisationsError.noOrganisations)
                    return
                }
                
                let hasMultipleOrganisations = organisations.count == 1 ? false : true
                weakSelf.sessionRepository.setHasMultipleOrganisations(hasMultipleOrganisations: hasMultipleOrganisations)
                
                seal.fulfill(organisations)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func setSelectedOrganisation(organisation: Organisation) {
        sessionRepository.setSelectedOrganisation(organisation: organisation)
    }

    func getAdditionalOrganisationDetails(organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            let userInfoPromise = getUserInfo(organisationID: organisationID)
            let navigationPromise = getOrganisationNavigationMenu(organisationID: organisationID)
            
            when(fulfilled: userInfoPromise, navigationPromise).done { (userInfoResponse, navigationEntries) in
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    func createExChangesToken(orgId: String, memberId: String) -> Promise<Bool> {
        return Promise { seal in
            print(orgId,memberId)
            organisationsRepository.getExchangeToken(org_id: orgId, member_id: memberId).done { [weak self] response in
                guard let weakSelf = self else { return seal.reject(LoginError.unknownError) }
                
                if response.success == true {
                    
                    // here set the user default true or false and access loginview controller variable
                    // set here sessiontoken save
//                    if let sessionToken = response.sessionToken {
//                        weakSelf.sessionRepository.setSessionToken(sessionToken: sessionToken)
//
//                        weakSelf.loginRepository.setUsedEmailAddress(email: username)
//
                    if  response.tempToken.isEmpty == false && response.memberId.isEmpty == false && response.orgId.isEmpty == false {
                        MembershipAPIRouter.tempSessionTokenStr = response.tempToken
                        seal.fulfill(true)
                    } else {
                        seal.reject(LoginError.sessionTokenError)
                    }
                } else if let errorMessage = response.errorMessage {
                    print(response.errorMessage)
                    seal.reject(LoginError.errorMessage(message: errorMessage))
                } else {
                    print(LoginError.unknownError)
                    seal.reject(LoginError.unknownError)
                }
            }.catch { error in
                print(error)
                seal.reject(error)
            }
        }
    }
    func exchangeToken(tokenstrs: String) -> Promise<Bool> {
        return Promise { seal in
            organisationsRepository.exchangeTokn(tokenstr:tokenstrs).done { [weak self] response in
                guard let weakSelf = self else { return seal.reject(LoginError.unknownError) }
                
                if response.success == true {
                    if  response.sessionToken.isEmpty == false {
                        UserDefaults.standard.set(MembershipAPIRouter.tempMemberIDStr, forKey: "memberID")
                        UserDefaults.standard.set(MembershipAPIRouter.tempOrgIDStr, forKey: "orgID")
                        weakSelf.sessionRepository.setSessionToken(sessionToken: response.sessionToken)
                        UserDefaults.standard.set(MembershipAPIRouter.homeURLStr!, forKey: "homeUrl")
                        weakSelf.viewOrgs?.changePageToWebContent(url: MembershipAPIRouter.homeURLStr!)
                        seal.fulfill(true)
                    } else {
                        seal.reject(LoginError.sessionTokenError)
                    }
                } else if let errorMessage = response.errorMessage {
                    print(response.errorMessage)
                    seal.reject(LoginError.errorMessage(message: errorMessage))
                } else {
                    print(LoginError.unknownError)
                    seal.reject(LoginError.unknownError)
                }
            }.catch { error in
                print(error)
                seal.reject(error)
            }
        }
    }
    func getUserInfo(organisationID: String) -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(OrganisationsError.sessionTokenError)
                return
            }
            
            organisationsRepository.getUserInfo(sessionToken: sessionToken, organisationID: organisationID).done { [weak self] response in
                guard let weakSelf = self else { return }
                let userInfo = UserInfo(email: response.email, firstName: response.firstName, lastName: response.lastName, avatarUrl: response.avatarUrl, initialCartCount: response.initialCartCount, ablyAPIKey: response.ablyAPIKey, ablyChannel: response.ablyChannel, unreadOrgNotifications: response.unreadOrgNotifications, orgUnreadCounts: response.orgUnreadCounts,end_points: response.end_points,mtkAdmin: response.mtkAdmin)
                weakSelf.sessionRepository.setUserInfo(userInfo: userInfo)

                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    
    func getUserInfo() -> UserInfo? {
        return sessionRepository.getSession()?.userInfo;
    }
    
    func getOrganisationNavigationMenu(organisationID: String) -> Promise<Array<NavigationEntry>> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(OrganisationsError.sessionTokenError)
                return
            }
            
            organisationsRepository.getNavigationMenu(sessionToken: sessionToken, organisationID: organisationID).done { [weak self] response in
                guard let weakSelf = self else { return }
                if let navigationMenuEntries = response.menuEntries, let settingsMenuEntries = response.settingsEntries, let orgInfo = response.orgInfo {
                    weakSelf.sessionRepository.setNavigationMenu(entries: navigationMenuEntries)
                    weakSelf.sessionRepository.setSettingsMenu(entries: settingsMenuEntries)
                    weakSelf.sessionRepository.setSelectedOrganisation(organisation: orgInfo)
                    seal.fulfill(navigationMenuEntries)
                } else {
                    seal.reject(OrganisationsError.noNavigationMenuEntries)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func registerDeviceForPushNotifications() -> Promise<BaseResponse> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(OrganisationsError.sessionTokenError)
                return
            }
            
            let deviceName = "\(UIDevice.current.name) (\(UIDevice.current.model))"
            print("session token:",sessionToken)
            notificationsRepository.registerDeviceForPushNotifications(sessionToken: sessionToken, deviceName: deviceName).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func hasAskedEnableNotificationsPopup() -> Bool {
        return notificationsRepository.hasAskedEnableNotificationsPopup()
    }
    
    func setAskedEnableNotificationsPopup(shown: Bool) {
        notificationsRepository.setAskedEnableNotificationsPopup(shown: shown)
    }
    
    func logoutUser() -> Promise<Bool> {
        return Promise { seal in
            let unregisterNotificationsPromise = unregisterDeviceForNotifications()
            let logoutRequestPromise = logoutRequest()
            //Logout api request
            when(fulfilled: unregisterNotificationsPromise, logoutRequestPromise).done { (unregisterResponse, logoutResponse) in
            }.catch { (error) in
                print(error)
            }.finally { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.clearAppData()
                seal.fulfill(true)
            }
        }
    }
    
    fileprivate func logoutRequest() -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError)}
            
            loginRepository.logoutUser(sessionToken: sessionToken).done { response in
                seal.fulfill(true)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    fileprivate func unregisterDeviceForNotifications() -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError)}
            
            let notificationsEnabledState = notificationsRepository.notificationsEnabledState()
            if notificationsEnabledState == true {
                //unregister device
                notificationsRepository.unregisterDeviceForPushNotifications(sessionToken: sessionToken).done { (response) in
                    seal.fulfill(true)
                }.catch { (error) in
                    seal.reject(error)
                }
            } else {
                //notification arent enabled so no need to unregister
                seal.fulfill(true)
            }
        }
    }
    
    fileprivate func clearAppData() {
        //Remove local user data
        sessionRepository.clearUserData()
    }
}
