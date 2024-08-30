//
//  BasketRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 12/03/2019.
//  
//

import Foundation

class BasketRepository {
    fileprivate var basketLocalSource: BasketLocalSource
    
    init(basketLocalSource: BasketLocalSource) {
        self.basketLocalSource = basketLocalSource
    }
    
    func getBasketCount() -> Int {
        return basketLocalSource.getBasketCount()
    }
    
    func setInitialBasketCount(count: Int) {
        basketLocalSource.setInitialBasketCount(count: count)
    }
    
    func setupAbly(key: String, channel: String) {
        basketLocalSource.setupAbly(key: key, channel: channel)
    }
    
    func unsubscribeFromBasketUpdates() {
        basketLocalSource.unsubscribeFromCurrentChannel()
    }
}

