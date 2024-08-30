//
//  WebContentInteractor.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class WebContentInteractor {
    fileprivate var sessionRepository: SessionRepository
    fileprivate var basketRepository: BasketRepository
    
    init(sessionRepository: SessionRepository, basketRepository: BasketRepository) {
        self.sessionRepository = sessionRepository
        self.basketRepository = basketRepository
    }
    
    func getBasketCount() -> Int {
        return basketRepository.getBasketCount()
    }
    
    func buildWebUrl(endpoint: String) -> String {
        guard let session = sessionRepository.getSession() else { fatalError("Can't get session") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Can't get selected organization") }
        guard let baseUrl = selectedOrganisation.baseUrl else { fatalError("Base url not set") }
        guard let sessionToken = session.sessionToken else { fatalError("No session token") }
        
        let endpointEncoded = endpoint.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? endpoint
        
        return baseUrl + "/api/mobile-redirect/" + sessionToken + "?r=" + endpointEncoded
    }
    
    func getInternalDomains() -> Array<String> {
        guard let session = sessionRepository.getSession() else { fatalError("Cant' get session") }
        guard let selectedOrganisation = session.selectedOrganisation else { fatalError("Can't get selected organization") }
        let internalDomains = selectedOrganisation.internalDomains ?? []
        return internalDomains
    }
    func removeLocalDataSessions()
    {
        sessionRepository.clearUserData()
    }
}
