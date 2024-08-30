//
//  LocationIdRepository.swift
// ClubExpress
//
//  Created by Ronit Patel on 12/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
import PromiseKit

class StripeLocationIdRepository {
    fileprivate var membershipRemoteSource: MembershipRemoteSource
    
    init(membershipRemoteSource: MembershipRemoteSource) {
        self.membershipRemoteSource = membershipRemoteSource
    }
    
    func getLocationIdStripe(sessionToken: String) -> Promise<LocationIdStripeResponse> {
        return Promise { seal in
            membershipRemoteSource.getLocationId(sessionToken: sessionToken).done { response in
                seal.fulfill(response)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
        
}
