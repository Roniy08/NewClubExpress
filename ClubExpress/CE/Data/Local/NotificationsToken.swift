//
//  NotificationsToken.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 19/03/2019.
//  
//

import Foundation
import PromiseKit
import Firebase

protocol NotificationsToken {
    func getLatestNotificationsToken() -> Promise<String>
}

class FirebaseNotificationsToken: NotificationsToken {
    func getLatestNotificationsToken() -> Promise<String> {
        return Promise { seal in
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                    seal.reject(error)
                } else if let token = token {
                    print("Remote instance ID token: \(token)")
                    seal.fulfill(token)
                }
                
            }
//            InstanceID.instanceID().instanceID { (result, error) in
//                if let error = error {
//                    print("Error fetching remote instance ID: \(error)")
//                    seal.reject(error)
//                } else if let result = result {
//                    print("Remote instance ID token: \(result.token)")
//                    seal.fulfill(result.token)
//                }
//            }
        }
    }
}
