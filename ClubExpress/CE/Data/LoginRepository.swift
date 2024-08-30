//
//  LoginRepository.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation
import PromiseKit

class LoginRepository {
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    fileprivate var userDefaultsSource: UserDefaultsSource
    
    init(membershipRemoteSource: MembershipRemoteSource, userDefaultsSource: UserDefaultsSource) {
        self.membershipRemoteSource = membershipRemoteSource
        self.userDefaultsSource = userDefaultsSource
    }

    func initRequest() -> Promise<InitResponse> {
        return Promise { seal in
            membershipRemoteSource.initRequest().done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func login(username: String, password: String) -> Promise<LoginResponse> {
        return Promise { seal in
            membershipRemoteSource.login(username: username, password: password).done { response in
                seal.fulfill(response)
              
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func exchangeTokn(tokenstr: String) -> Promise<ExchangeTokenResponse> {
        return Promise { seal in
            membershipRemoteSource.exchangeTokn(token: tokenstr).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
        
    }
       func logoutUser(sessionToken: String) -> Promise<BaseResponse> {
        return Promise { seal in
            membershipRemoteSource.logout(sessionToken: sessionToken).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getPreviouslyUsedEmailAddress() -> String? {
        return userDefaultsSource.getEmailAddress()
    }
    
    func setUsedEmailAddress(email: String) {
        userDefaultsSource.setEmailAddress(email: email)
    }
}
