//
//  CalendarEventResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 11/02/2019.
//  
//

import Foundation

class CalendarEventResponse: Decodable {
    let title: String?
    let eventDescription: String?
    let upcomingDates: Array<CalendarEventUpcomingDate>?
    let calendarID: String?
    let ads: Array<NativeAd>?
    
    private enum CodingKeys: String, CodingKey {
        case title = "entry_title"
        case eventDescription = "entry_description"
        case upcomingDates = "entry_date"
        case calendarID = "calendar_id"
        case ads = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try? container.decode(String.self, forKey: .title)
        self.eventDescription = try? container.decode(String.self, forKey: .eventDescription)
        self.upcomingDates = try? container.decode(Array<CalendarEventUpcomingDate>.self, forKey: .upcomingDates)
        self.calendarID = try? container.decode(String.self, forKey: .calendarID)
        self.ads = try? container.decode(Array<NativeAd>?.self, forKey: .ads)
    }
}
