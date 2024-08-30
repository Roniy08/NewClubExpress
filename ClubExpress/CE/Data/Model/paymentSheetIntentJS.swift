//
//  paymentSheetIntentJS.swift
// ClubExpress
//
//  Created by Ronit Patel on 09/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
class UserPaymentSheetJSData {
    var command : String? = ""
    var stripe_publishable_key : String? = ""
    var connected_account_id : String? = ""
    var payment_intent_id : String? = ""
    var location_id : String? = ""
    var client_secret : String? = ""
    
    
    
    init(_ command:String,stripe_publishable_key:String,connected_account_id:String,payment_intent_id:String,location_id:String,client_secret:String) {
        self.command = command
        self.stripe_publishable_key = stripe_publishable_key
        self.connected_account_id = connected_account_id
        self.payment_intent_id = payment_intent_id
        self.location_id = location_id
        self.client_secret = client_secret
        
    }
}
