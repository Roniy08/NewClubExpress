//
//  CalendarEventsResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 01/02/2019.
//  
//

import Foundation

class CalendarEventsResponse: Decodable {
    let entries: Array<CalendarEvent>?
    let showAds: Array<NativeAd>

    private enum CodingKeys: String, CodingKey {
        case entries = "entries"
        case showAds = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.entries = try? container.decode(Array<CalendarEvent>.self, forKey: .entries)
        if let showAds = try? container.decode(Array<NativeAd>.self, forKey: .showAds), showAds != nil {
            self.showAds = showAds
        } else {
            self.showAds = []
        }
    }
}
