//
//  DirectoryResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class DirectoryResponse: Decodable {
    let entries: Array<DirectoryEntry>
    let showAds: Array<NativeAd>
    
    private enum CodingKeys: String, CodingKey {
        case entries = "entries"
        case showAds = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.entries = try container.decode(Array<DirectoryEntry>.self, forKey: .entries)
        if let showAds = try? container.decode(Array<NativeAd>.self, forKey: .showAds), showAds != nil {
            self.showAds = showAds
        } else {
            self.showAds = []
        }
    }
}
