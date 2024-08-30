//
//  DirectoryFilterOption.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryFilterOption: Decodable {
    let name: String?
    let value: String?
    
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.value = try? container.decode(String.self, forKey: .value)
    }
}
