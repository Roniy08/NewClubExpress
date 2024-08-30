//
//  CalendarEventUpcomingDate.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 11/02/2019.
//  
//

import Foundation

class CalendarEventUpcomingDate: Decodable {
    var startTimestamp: Int?
    var endTimestamp: Int?
    var allDay: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case startTimestamp = "timestamp_start"
        case endTimestamp = "timestamp_end"
        case allDay = "all_day"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.startTimestamp = try? container.decode(Int.self, forKey: .startTimestamp)
        self.endTimestamp = try? container.decode(Int.self, forKey: .endTimestamp)
        self.allDay = try? container.decode(Bool.self, forKey: .allDay)
    }
}
