//
//  CalendarEvent.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 01/02/2019.
//  
//

import Foundation

class CalendarEvent: Decodable {
    var id: String?
    var title: String?
    var calendarID: String?
    var startTimestamp: Int?
    var endTimestamp: Int?
    var allDay: Bool?
    var parentCalendar: OrgCalendar?
    var startTime: String?
    var endTime: String?
    var startDate: Date?
    var endDate: Date?
    var showAds: Array<NativeAd>?
    
    private enum CodingKeys: String, CodingKey {
        case id = "entry_id"
        case title = "entry_title"
        case calendarID = "calendar_id"
        case startTimestamp = "entry_start_timestamp"
        case endTimestamp = "entry_end_timestamp"
        case allDay = "entry_all_day"
        case showAds = "show-ad"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.title = try? container.decode(String.self, forKey: .title)
        self.calendarID = try? container.decode(String.self, forKey: .calendarID)
        self.startTimestamp = try? container.decode(Int.self, forKey: .startTimestamp)
        self.endTimestamp = try? container.decode(Int.self, forKey: .endTimestamp)
        self.allDay = try? container.decode(Bool.self, forKey: .allDay)
        if let showAds = try? container.decode(Array<NativeAd>.self, forKey: .showAds), showAds != nil {
            self.showAds = showAds
        } else {
            self.showAds = []
        }
    }
}
