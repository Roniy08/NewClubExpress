//
//  ConnectiontokenRepository.swift
// ClubExpress
//
//  Created by Ronit Patel on 19/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
import PromiseKit

class CoonectionTokenRepository {
    
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    init(membershipRemoteSource: MembershipRemoteSource) {
        self.membershipRemoteSource = MembershipRemoteSource.self as! any MembershipRemoteSource
    }
    func getConnectionToken(sessionToken: String) -> Promise<ConnectionTokenResponse> {
        return Promise { seal in
            membershipRemoteSource.getConnectionToken(sessionToken: sessionToken).done { response in
                seal.fulfill(response)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}
