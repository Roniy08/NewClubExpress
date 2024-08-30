//
//  OrganisationWrapperInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class OrganisationWrapperInteractor {
var sessionRepository: SessionRepository
    fileprivate var loginRepository: LoginRepository
    fileprivate var directoryRepository: DirectoryRepository
    fileprivate var calendarRepository: CalendarRepository
    fileprivate var basketRepository: BasketRepository
    fileprivate var organisationsRepository: OrganisationsRepository
    var notificationsCountRepository: NotificationsCountRepository
    var notificationsRepository: NotificationsRepository
    
    init(sessionRepository: SessionRepository, loginRepository: LoginRepository, directoryRepository: DirectoryRepository, calendarRepository: CalendarRepository, basketRepository: BasketRepository, organisationsRepository: OrganisationsRepository, notificationsCountRepository: NotificationsCountRepository, notificationsRepository: NotificationsRepository) {
        self.sessionRepository = sessionRepository
        self.loginRepository = loginRepository
        self.directoryRepository = directoryRepository
        self.calendarRepository = calendarRepository
        self.basketRepository = basketRepository
        self.organisationsRepository = organisationsRepository
        self.notificationsCountRepository = notificationsCountRepository
        self.notificationsRepository = notificationsRepository
    }
    
    func clearSelectedOrganisationData() {
        sessionRepository.clearSelectedOrganisationData()
        calendarRepository.clearCalendarData()
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
    
    func logoutRequest() -> Promise<Bool> {
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
    
    func unregisterDeviceForNotifications() -> Promise<Bool> {
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
    
    func clearAppData() {
        //Remove local user data
        sessionRepository.clearUserData()
        directoryRepository.clearAllAppliedFilters()
        calendarRepository.clearCalendarData()
        MembershipAPIRouter.tempSessionTokenStr = ""
    }
    
    func hasSwitchOrganisationPopupShown() -> Bool {
        return sessionRepository.hasSwitchOrganisationPopupShown()
    }
    
    func setShownSwitchOrganisationPopup() {
        sessionRepository.setShownSwitchOrganisationPopup()
    }
    
    func setInitialBasketCount() {
        guard let session = sessionRepository.getSession() else { fatalError("Can't get session") }
        guard let userInfo = session.userInfo else { fatalError("Can't get user info") }
        
        if let initialCartCount = userInfo.initialCartCount {
            basketRepository.setInitialBasketCount(count: initialCartCount)
        }
    }
    
    func connectToAbly() {
        let key = getAblyAPIKey()
        let channel = getAblyChannel()
        basketRepository.setupAbly(key: key, channel: channel)
    }
    
    fileprivate func getAblyAPIKey() -> String {
        guard let session = sessionRepository.getSession() else { return "" }
        guard let userInfo = session.userInfo else { return "" }
        
        if let ablyAPIKey = userInfo.ablyAPIKey {
            return ablyAPIKey
        }
        return ""
    }
    
    fileprivate func getAblyChannel() -> String {
        guard let session = sessionRepository.getSession() else { return "" }
        guard let userInfo = session.userInfo else { return "" }

        if let ablyChannel = userInfo.ablyChannel {
            return ablyChannel
        }
        return ""
    }
    
    func unsubscribeFromBasketUpdates() {
        basketRepository.unsubscribeFromBasketUpdates()
    }
    
    func getHomeContent() -> Promise<HomeResponse> {
        return Promise { seal in
            guard let session = sessionRepository.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError) }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(LoginError.unknownError)
                return
            }
            
            organisationsRepository.getHomeContent(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getCheckoutUrl() -> String {
        guard let session = sessionRepository.getSession() else { fatalError("Cant' get session") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Can't get selected organization") }
        let checkoutUrl = selectedOrganisation.checkoutUrl ?? ""
        return checkoutUrl
    }
    
    func setInitialUnreadOrgNotificationsCount() {
        guard let session = sessionRepository.getSession() else { fatalError("Cant' get session") }
        guard let userInfo = session.userInfo else { fatalError("No user info found") }
        
        let unreadCount = Int(userInfo.unreadOrgNotifications ?? "0") ?? 0
        
        notificationsCountRepository.setUnreadCount(count: unreadCount)
        
        var badgeCount = 0
        for org in userInfo.orgUnreadCounts ?? [:] {
            badgeCount += Int(org.value) ?? 0
        }
        UserDefaults.standard.set("\(badgeCount - unreadCount)", forKey: "otherAppUnreadCount")
        UserDefaults.standard.set("\(badgeCount)", forKey: "UpdateCount")
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        
//        notificationsCountRepository.setBadge(orgCount: unreadCount, allOrgCount: userInfo.orgUnreadCounts!)
    }
    
    func getUnreadOrgNotificationsCount() -> Int {
        return notificationsCountRepository.getUnreadCount()
    }

    func getRemoteOrgNotificationsCount() -> Int {
        var userInfo = self.sessionRepository.getSession()?.userInfo
        var totalCount = 0
        for org in userInfo?.orgUnreadCounts ?? [:] {
            totalCount += Int(org.value) ?? 0
        }
        return totalCount
    }
    
    func setUnreadOrgNotificationsCount(count: Int) {
        notificationsCountRepository.setUnreadCount(count: count)
    }
    
    func getCurrentOrganisationID() -> String {
        guard let session = sessionRepository.getSession() else { return "" }
        guard let selectedOrganisation = session.selectedOrganisation else { return "" }
        return selectedOrganisation.id ?? ""
    }
    
    func refreshUnreadCount() -> Promise<Int> {
        return Promise { seal in
            guard let session = sessionRepository.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError) }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(LoginError.unknownError)
                return
            }
            
            organisationsRepository.refreshUnreadCount(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func refreshCurrentOrgUnreadCount() -> Promise<Int> {
        return Promise { seal in
            guard let session = sessionRepository.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError) }
            
            guard let organisation = session.selectedOrganisation, let organisationID = organisation.id else {
                seal.reject(LoginError.unknownError)
                return
            }
            
            organisationsRepository.refreshUnreadCurrentCount(sessionToken: sessionToken, organisationID: organisationID).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
