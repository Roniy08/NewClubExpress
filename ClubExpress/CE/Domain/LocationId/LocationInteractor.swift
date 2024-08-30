//
//  LocationInteractor.swift
// ClubExpress
//
//  Created by Ronit Patel on 12/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
import PromiseKit

enum LocationError: Error {
    case sessionTokenError
    case unknownError
}

class LocationIdInteractor {
    fileprivate var locationRepository: StripeLocationIdRepository
    var sessionRepository: SessionRepository
    
    init(locationRepository: StripeLocationIdRepository,sessionRepository: SessionRepository) {
        self.locationRepository = locationRepository
        self.sessionRepository = sessionRepository
    }
    
    func locationIdRecived() -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepository.getSession(), let sessionToken = session.sessionToken else {
                seal.reject(LocationError.sessionTokenError)
                return
            }
            locationRepository.getLocationIdStripe(sessionToken: sessionToken).done { [weak self] response in
                guard let weakSelf = self else { return seal.reject(LocationError.unknownError) }

                if response.status == true {
                    print(response.stripe_location_id)
                   
                } else {
                    seal.reject(LoginError.unknownError)
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
}
