//
//  OrganisationsResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class OrganisationsResponse: Decodable {
    let orgs: Array<Organisation>
    let count: Int
    let key: String?
    
    private enum CodingKeys: String, CodingKey {
        case orgs = "orgs"
        case count = "count"
        case key = "total_unread_count"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decode(Int.self, forKey: .count)
        self.orgs = try container.decode(Array<Organisation>.self, forKey: .orgs)
        self.key = try container.decode(String.self, forKey: .key)
    }
}
