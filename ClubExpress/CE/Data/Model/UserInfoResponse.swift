//
//  UserInfoResponse.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 09/01/2019.
//  
//

import Foundation

class UserInfoResponse: Decodable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let initialCartCount: Int?
    let ablyAPIKey: String?
    let ablyChannel: String?
    let unreadOrgNotifications: String?
    let orgUnreadCounts: [String: String]?
    let end_points: [[String:String]]?
    let mtkAdmin: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case email = "email"
        case firstName = "firstname"
        case lastName = "lastname"
        case avatarUrl = "avatar_url"
        case initialCartCount = "cart_count"
        case ablyAPIKey = "ably_api_subscribe_key"
        case ablyChannel = "ably_cart_channel"
        case unreadOrgNotifications = "unread_count"
        case orgUnreadCounts = "org_unread_counts"
        case end_points = "endpoints"
        case mtkAdmin = "mtk_admin"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try? container.decode(String.self, forKey: .email)
        self.firstName = try? container.decode(String.self, forKey: .firstName)
        self.lastName = try? container.decode(String.self, forKey: .lastName)
        self.avatarUrl = try? container.decode(String.self, forKey: .avatarUrl)
        self.initialCartCount = try? container.decode(Int.self, forKey: .initialCartCount)
        self.ablyAPIKey = try? container.decode(String.self, forKey: .ablyAPIKey)
        self.ablyChannel = try? container.decode(String.self, forKey: .ablyChannel)
        self.unreadOrgNotifications = try? container.decode(String.self, forKey: .unreadOrgNotifications)
        self.orgUnreadCounts = try? container.decode([String: String]?.self, forKey: .orgUnreadCounts)
        self.end_points = try? container.decode([[String:String]]?.self, forKey: .end_points)
        self.mtkAdmin = try? container.decode(Bool?.self, forKey: .mtkAdmin)
    }
}
struct OrgUnreadCounts: Decodable {
    let id: String
    let count: Int
}
