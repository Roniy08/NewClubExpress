//
//  BasketLocalSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 27/02/2019.
//  
//

import Foundation
import Ably
import PromiseKit

protocol BasketLocalSource {
    func setupAbly(key: String, channel: String)
    func setInitialBasketCount(count: Int)
    func getBasketCount() -> Int
    func unsubscribeFromChannel(channel: String)
    func unsubscribeFromCurrentChannel()
}

enum BasketLocalSourceError: Error {
    case emptyApiKey
    case errorConnecting
}

class BasketLocalSourceImpl: BasketLocalSource {
    fileprivate var ably: ARTRealtime?
    fileprivate var currentChannel: String?
    
    fileprivate var basketCount = 0 {
        didSet {
            basketCountDidChange()
        }
    }
    
    func setInitialBasketCount(count: Int) {
        self.basketCount = count
    }
    
    func getBasketCount() -> Int {
        return basketCount
    }
    
    func setupAbly(key: String, channel: String) {
        connect(key: key).done { [weak self] success in
            guard let weakSelf = self else { return }
            weakSelf.subscribeToChannel(channel: channel)
        }.catch { error in
            print("could not connect to ably: \(error.localizedDescription)")
        }
    }
    
    fileprivate func connect(key: String) -> Promise<Bool> {
        return Promise { seal in
            if key.count > 0 {
                ably = ARTRealtime(key: key)

                ably?.connection.on(.connected, callback: { (state) in
                    seal.fulfill(true)
                })
                ably?.connection.on(.failed, callback: { (state) in
                    print("error connecting to Ably")
//                    Initializer for conditional binding must have Optional type, not 'ARTConnectionStateChange'
//                    if let state = state, let error = state.reason {
                        if let error = state.reason {

                        let errorMessage = error.message
                        print(errorMessage)
                    }
                    seal.reject(BasketLocalSourceError.errorConnecting)
                })
            } else {
                seal.reject(BasketLocalSourceError.emptyApiKey)
            }
        }
    }
    
    fileprivate func subscribeToChannel(channel: String) {
        guard channel.count > 0 else {
            print("channel empty")
            return
        }
        
        let ablyChannel = ably?.channels.get(channel)
        ablyChannel?.subscribe({ (message) in
            if let data = message.data {
                print("Ably channel message: \(data)")
                if let dataDict = data as? Dictionary<String,Any> {
                    self.channelDataReceived(dict: dataDict)
                }
            }
        })
        
        self.currentChannel = channel
        
        print("Ably subscribed to channel: \(channel)")
    }
    
    func unsubscribeFromChannel(channel: String) {
        guard channel.count > 0 else { return }
        
        let ablyChannel = ably?.channels.get(channel)
        ablyChannel?.unsubscribe()
        
        print("Ably unsubscribed from channel: \(channel)")
    }
    
    func unsubscribeFromCurrentChannel() {
        guard let channel = self.currentChannel else { return }
        unsubscribeFromChannel(channel: channel)
    }
    
    fileprivate func channelDataReceived(dict: Dictionary<String,Any>) {
        if let basketCount = dict["cart_count"] as? Int {
            self.basketCount = basketCount
        }
    }
    
    fileprivate func basketCountDidChange() {
        let notificationName = Notification.Name.init("BasketCountChange")
        let userInfo = ["basketCount" : self.basketCount]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
}
