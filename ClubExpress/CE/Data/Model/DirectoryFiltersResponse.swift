//
//  DirectoryFiltersResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryFiltersResponse: Decodable {
    let filters: Array<DirectoryFilter>?
    
    private enum CodingKeys: String, CodingKey {
        case filters = "filters"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filters = try? container.decode(Array<DirectoryFilter>.self, forKey: .filters)
    }
}
