//
//  DirectoryEntryResponseDetailField.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryResponseDetailField: Decodable {
    let name: String?
    let label: String?
    let sortOrder: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name = "field_name"
        case label = "field_label"
        case sortOrder = "sort_order"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.label = try? container.decode(String.self, forKey: .label)
        self.sortOrder = try? container.decode(Int.self, forKey: .sortOrder)
    }
}
