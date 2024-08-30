//
//  CalendarsResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class CalendarsResponse: Decodable {
    let calendars: Array<OrgCalendar>?
    let showAds: Array<NativeAd>

    private enum CodingKeys: String, CodingKey {
        case calendars = "calendars"
        case showAds = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.calendars = try? container.decode(Array<OrgCalendar>.self, forKey: .calendars)
//        self.showAds = try container.decode(Array<NativeAd>.self, forKey: .showAds)
        if let showAds = try? container.decode(Array<NativeAd>.self, forKey: .showAds), showAds != nil {
            self.showAds = showAds
        } else {
            self.showAds = []
        }
    }
}
