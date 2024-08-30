//
//  NotificationsRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/03/2019.
//  
//

import Foundation
import PromiseKit

enum NotificationsRepositoryError: Error {
    case unknownError
}

class NotificationsRepository {
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    fileprivate var userDefaultsSource: UserDefaultsSource
    fileprivate var notificationsToken: NotificationsToken

    init(membershipRemoteSource: MembershipRemoteSource, userDefaultsSource: UserDefaultsSource, notificationsToken: NotificationsToken) {
        self.membershipRemoteSource = membershipRemoteSource
        self.userDefaultsSource = userDefaultsSource
        self.notificationsToken = notificationsToken
    }

    func registerDeviceForPushNotifications(sessionToken: String, deviceName: String) -> Promise<BaseResponse> {
        return Promise { seal in
            getCurrentNotificationsToken().done { [weak self] deviceToken in
                guard let weakSelf = self else { return seal.reject(NotificationsRepositoryError.unknownError) }
                
                weakSelf.membershipRemoteSource.registerDeviceForPushNotifications(sessionToken: sessionToken, deviceToken: deviceToken, deviceName: deviceName).done { [weak self] response in
                    guard let weakSelf = self else { return }
                    
                    weakSelf.userDefaultsSource.setNotificationsToken(token: deviceToken)
                    weakSelf.userDefaultsSource.setDeviceName(name: deviceName)
                    
                    seal.fulfill(response)
                }.catch { error in
                    seal.reject(error)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func unregisterDeviceForPushNotifications(sessionToken: String) -> Promise<BaseResponse> {
        return Promise { seal in
            guard let deviceToken = userDefaultsSource.getNotificationsToken() else { return }

            membershipRemoteSource.unregisterDeviceForPushNotifications(sessionToken: sessionToken, deviceToken: deviceToken).done { [weak self] response in
                guard let weakSelf = self else { return }
                
                weakSelf.userDefaultsSource.clearNotificationsToken()
                
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func notificationsEnabledState() -> Bool {
        if let _ = userDefaultsSource.getNotificationsToken() {
            return true
        }
        return false
    }
    
    func toggleNotifications(sessionToken: String) -> Promise<BaseResponse> {
        let currentlyEnabled = notificationsEnabledState()
        if currentlyEnabled {
            //Disable
            return unregisterDeviceForPushNotifications(sessionToken: sessionToken)
        } else {
            //Enable
            let deviceName = userDefaultsSource.getDeviceName()
            
            return registerDeviceForPushNotifications(sessionToken: sessionToken, deviceName: deviceName)
        }
    }
    
    fileprivate func getCurrentNotificationsToken() -> Promise<String> {
        return Promise { seal in
            notificationsToken.getLatestNotificationsToken().done { (token) in
                seal.fulfill(token)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func checkForUpdatedNotificationsToken(sessionToken: String) -> Promise<Bool> {
        return Promise { seal in
            guard let existingToken = userDefaultsSource.getNotificationsToken(), existingToken.count > 0 else {
                //no token saved or notifications disabled so no need to refresh
                seal.fulfill(true)
                return
            }
            
            notificationsToken.getLatestNotificationsToken().then { [weak self] (latestToken) -> Promise<Bool> in
                guard let weakSelf = self else { return Promise(error: NotificationsRepositoryError.unknownError) }
                if existingToken == latestToken {
                    //token unchanged
                    return Promise { seal in
                        seal.fulfill(true)
                    }
                } else {
                    return weakSelf.updateNotificationsToken(existingNotificationsToken: existingToken, newNotificationsToken: latestToken, sessionToken: sessionToken)
                }
            }.done { success in
                seal.fulfill(success)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func updateNotificationsToken(existingNotificationsToken: String, newNotificationsToken: String, sessionToken: String ) -> Promise<Bool> {
        return Promise { seal in
            //unregister old token then register new token
            unregisterDeviceForPushNotifications(sessionToken: sessionToken).then { [weak self] (unregisterOldTokenResponse) -> Promise<BaseResponse> in
                guard let weakSelf = self else { return Promise(error: NotificationsRepositoryError.unknownError) }
                
                if let unregisteredSuccess = unregisterOldTokenResponse.success, unregisteredSuccess == true {
                    let deviceName = weakSelf.userDefaultsSource.getDeviceName()
                    return weakSelf.registerDeviceForPushNotifications(sessionToken: sessionToken, deviceName: deviceName)
                } else {
                    return Promise(error: NotificationsRepositoryError.unknownError)
                }
            }.done { (registerNewTokenResponse) in
                if let registeredSuccess = registerNewTokenResponse.success, registeredSuccess == true {
                    seal.fulfill(registeredSuccess)
                } else {
                    seal.reject(NotificationsRepositoryError.unknownError)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func hasAskedEnableNotificationsPopup() -> Bool {
        return userDefaultsSource.hasAskedEnableNotificationsPopup()
    }
    
    func setAskedEnableNotificationsPopup(shown: Bool) {
        userDefaultsSource.setAskedEnableNotificationsPopup(shown: shown)
    }
}
