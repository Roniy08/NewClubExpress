//
//  ConnectReaderResponse.swift
// ClubExpress
//
//  Created by Ronit Patel on 14/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
import Foundation
class ReaderConnectData {
    var command : String? = ""
    var location_id : String? = ""
    
    
    
    init(_ command:String,location_id:String) {
        self.command = command
        self.location_id = location_id
        
    }
}
