//
//  Session.swift
// ClubExpress
//
// Created by Ronit on 05/06/2024.
//  
//

import Foundation

struct Session {
    var sessionToken: String?
    var userInfo: UserInfo?
    var selectedOrganisation: Organisation?
    var hasMultipleOrganisations: Bool?
    var navigationEntries: Array<NavigationEntry>?
    var settingsEntries: Array<NavigationEntry>?
    var ablyAPIKey: String?
}
