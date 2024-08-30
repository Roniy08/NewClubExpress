//
//  BailToBackData.swift
// ClubExpress
//
//  Created by Ronit Patel on 08/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
class UserResponseJSData {
    var command : String? = ""
    var dataContent : String? = ""
    
    
    init(_ command:String,dataContent:String) {
        self.command = command
        self.dataContent = dataContent
    }
}
