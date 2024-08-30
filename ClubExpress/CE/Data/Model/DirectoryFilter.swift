//
//  DirectoryFilter.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryFilter: Decodable {
    let name: String?
    let label: String?
    let options: Array<DirectoryFilterOption>?
    
    private enum CodingKeys: String, CodingKey {
        case name = "filter_name"
        case label = "filter_label"
        case options = "options"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.label = try? container.decode(String.self, forKey: .label)
        self.options = try? container.decode(Array<DirectoryFilterOption>.self, forKey: .options)
    }
}
