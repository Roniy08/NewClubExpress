//
//  HomeResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 22/03/2019.
//  
//

import Foundation

class HomeResponse: Decodable {
    let body: String?
    let homeUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case body = "body"
        case homeUrl = "home_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.body = try? container.decode(String.self, forKey: .body)
        print(self.body)
        self.homeUrl = try? container.decode(String.self, forKey: .homeUrl)
    }
}
