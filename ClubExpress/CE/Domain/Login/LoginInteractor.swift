//
//  LoginInteractor.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

enum LoginError: Error {
    case sessionTokenError
    case unknownError
    case errorMessage(message: String)
    case noLoginFooterMessage
}

class LoginInteractor {
    fileprivate var loginRepository: LoginRepository
    fileprivate var sessionRepository: SessionRepository
    fileprivate var notificationsRepository: NotificationsRepository
    var authDefaults = UserDefaults.standard

    init(loginRepository: LoginRepository, sessionRepository: SessionRepository,notificationRepositories:NotificationsRepository) {
        self.loginRepository = loginRepository
        self.sessionRepository = sessionRepository
        self.notificationsRepository = notificationRepositories
    }
    
    func getLoginFooterMessage() -> Promise<String> {
        return Promise { seal in
            loginRepository.initRequest().done { response in
                if let loginMessage = response.loginMessage {
                    seal.fulfill(loginMessage)
                } else {
                    seal.reject(LoginError.noLoginFooterMessage)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func login(username: String, password: String) -> Promise<Bool> {
        return Promise { seal in
            loginRepository.login(username: username, password: password).done { [weak self] response in
                guard let weakSelf = self else { return seal.reject(LoginError.unknownError) }
                
                if response.success == true {
                    
                    // here set the user default true or false and access loginview controller variable
                    // set here sessiontoken save
//                    if let sessionToken = response.sessionToken {
//                        weakSelf.sessionRepository.setSessionToken(sessionToken: sessionToken)
//
//                        weakSelf.loginRepository.setUsedEmailAddress(email: username)
//                        
//                        seal.fulfill(true)
//                    } else {
//                        seal.reject(LoginError.sessionTokenError)
//                    }
                    if response.orgs.count > 1
                    {
                        print("there is \(response.counts) organisations")
                        self!.saveOrgsToUserDefaults(orgs: response.orgs)
                        MembershipAPIRouter.storeorgCount = 0
                       
                    }
                    else if response.orgs.count == 1
                    {
                        print("there is one organisation")
                        MembershipAPIRouter.tempSessionTokenStr = response.orgs[0].temp_token
                        self!.saveOrgsToUserDefaults(orgs: response.orgs)
                        MembershipAPIRouter.storeorgCount = 1
                    }
                    else
                    {
                        print("no any organisations")
                    }
                    seal.fulfill(true)
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
    func saveOrgsToUserDefaults(orgs: [OrgLogin]) {
        do {
            let data = try JSONEncoder().encode(orgs)
            UserDefaults.standard.set(data, forKey: "orgsList")
        } catch {
            print("Failed to encode orgs: \(error.localizedDescription)")
        }
    }
    func exchangeToken(tokenstrs: String) -> Promise<Bool> {
        return Promise { seal in
            loginRepository.exchangeTokn(tokenstr:tokenstrs).done { [weak self] response in
                guard let weakSelf = self else { return seal.reject(LoginError.unknownError) }
                
                if response.success == true {
                    
                    // here set the user default true or false and access loginview controller variable
                    // set here sessiontoken save
//                    if let sessionToken = response.sessionToken {
//                        weakSelf.sessionRepository.setSessionToken(sessionToken: sessionToken)
//
//                        weakSelf.loginRepository.setUsedEmailAddress(email: username)
//
                    if  response.sessionToken.isEmpty == false {
                        UserDefaults.standard.set(MembershipAPIRouter.tempMemberIDStr, forKey: "memberID")
                        UserDefaults.standard.set(MembershipAPIRouter.tempOrgIDStr, forKey: "orgID")
                        weakSelf.sessionRepository.setSessionToken(sessionToken: response.sessionToken)
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
  
    func getPreviouslyUsedEmailAddress() -> String? {
        return loginRepository.getPreviouslyUsedEmailAddress()
    }
}
