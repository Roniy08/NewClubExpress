//
//  NavigationMenuResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class NavigationMenuResponse: Decodable {
    let name: String?
    let menuEntries: Array<NavigationEntry>?
    let settingsEntries: Array<NavigationEntry>?
    let orgInfo: Organisation?

    private enum CodingKeys: String, CodingKey {
        case name = "menu_name"
        case menuEntries = "menu_entries"
        case settingsEntries = "settings_entries"
        case orgInfo = "org_info"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.menuEntries = try? container.decode(Array<NavigationEntry>.self, forKey: .menuEntries)
        self.settingsEntries = try? container.decode(Array<NavigationEntry>.self, forKey: .settingsEntries)
        self.orgInfo = try? container.decode(Organisation.self, forKey: .orgInfo)
    }
}
