//
//  connectionTokenProtocol.swift
// ClubExpress
//
//  Created by Ronit Patel on 16/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
import PromiseKit


class ConnectionTokenInteractor {
   
    var secretString : String? = ""
    var sessionRepositorys: SessionRepository
    var coonectionTokenRepository: CoonectionTokenRepository
    init(sessionRepository: SessionRepository, connectionTokenRepository: CoonectionTokenRepository) {
        self.sessionRepositorys = sessionRepository
        self.coonectionTokenRepository = connectionTokenRepository
    }
    
    func getTokenConnection() -> Promise<Bool> {
        return Promise { seal in
            guard let session = sessionRepositorys.getSession() else { return seal.reject(LoginError.unknownError) }
            guard let sessionToken = session.sessionToken else { return seal.reject(LoginError.unknownError)}
            print(sessionToken)
            coonectionTokenRepository.getConnectionToken(sessionToken: sessionToken).done { [weak self] response in
                guard let weakSelf = self else { return }
                let organisations = response.status
//                secretString = response.connectionSecretString!
                print(organisations)
                seal.fulfill(organisations!)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

}
