//
//  OrgCalendar.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class OrgCalendar: Decodable {
    var id: String?
    var name: String?
    var colourCode: String?
    var icsUrl: String?
    var enabled: Bool? = true
    var subscribed: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id = "calendar_id"
        case name = "calendar_name"
        case colourCode = "calendar_color"
        case icsUrl = "ics_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.name = try? container.decode(String.self, forKey: .name)
        self.colourCode = try? container.decode(String.self, forKey: .colourCode)
        self.icsUrl = try? container.decode(String.self, forKey: .icsUrl)
    }
}
