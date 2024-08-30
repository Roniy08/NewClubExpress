//
//  DirectoryEntryResponseLabelStudent.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryEntryResponseLabelStudent: Decodable {
    let singular: String?
    let plural: String?
    
    private enum CodingKeys: String, CodingKey {
        case singular = "singular"
        case plural = "plural"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.singular = try? container.decode(String.self, forKey: .singular)
        self.plural = try? container.decode(String.self, forKey: .plural)
    }
}
