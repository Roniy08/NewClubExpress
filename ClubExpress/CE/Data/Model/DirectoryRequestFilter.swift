//
//  DirectoryRequestFilter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

struct DirectoryRequestFilter: Codable {
    var name: String
    var value: String
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
    }
    
}
