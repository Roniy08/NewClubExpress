//
//  SettingsItem.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 18/02/2019.
//  
//

import Foundation

enum settingsItemType {
    case webUrl(url: String)
    case toggleNotifications(enabled: Bool)
    case toggleAuth(enabled: Bool)
    case changeOrganisation
    case changeServer
    case connectReader
    case logOut
}

enum settingsItemAccessoryType {
    case nothing
    case arrow
    case toggleSwitch
}

enum settingsItemTextStyle {
    case normal
    case destructive
}

class SettingsItem {
    var title: String?
    var type: settingsItemType?
    var accessoryType: settingsItemAccessoryType?
    var textStyle: settingsItemTextStyle?
    
    init(title: String?, type: settingsItemType?, accessoryType: settingsItemAccessoryType?, textStyle: settingsItemTextStyle?) {
        self.title = title
        self.type = type
        self.accessoryType = accessoryType
        self.textStyle = textStyle
    }
}
