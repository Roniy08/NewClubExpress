//
//  UserInfo.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import Foundation

class UserInfo: NSObject, NSCoding {
    let email: String?
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let initialCartCount: Int?
    let ablyAPIKey: String?
    let ablyChannel: String?
    let unreadOrgNotifications: String?
    let orgUnreadCounts: [String: String]?
    let end_point: [[String:String]]?
    let mtkAdmin: Bool?

    init(email: String?, firstName: String?, lastName: String?, avatarUrl: String?, initialCartCount: Int?, ablyAPIKey: String?, ablyChannel: String?, unreadOrgNotifications: String?, orgUnreadCounts: [String: String]?,end_points: [[String:String]]?, mtkAdmin: Bool?) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
        self.initialCartCount = initialCartCount
        self.ablyAPIKey = ablyAPIKey
        self.ablyChannel = ablyChannel
        self.unreadOrgNotifications = unreadOrgNotifications
        self.orgUnreadCounts = orgUnreadCounts
        self.mtkAdmin = mtkAdmin
        self.end_point = end_points
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.avatarUrl, forKey: "avatarUrl")
        aCoder.encode(self.initialCartCount, forKey: "initialCartCount")
        aCoder.encode(self.ablyAPIKey, forKey: "ablyAPIKey")
        aCoder.encode(self.ablyChannel, forKey: "ablyChannel")
        aCoder.encode(self.unreadOrgNotifications, forKey: "unread_count")
        aCoder.encode(self.orgUnreadCounts, forKey: "org_unread_counts")
        aCoder.encode(self.mtkAdmin, forKey: "mtk_admin")
        aCoder.encode(self.end_point, forKey: "endpoints")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: "email") as? String
        let firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        let lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        let avatarUrl = aDecoder.decodeObject(forKey: "avatarUrl") as? String
        let initialCartCount = aDecoder.decodeObject(forKey: "initialCartCount") as? Int
        let ablyAPIKey = aDecoder.decodeObject(forKey: "ablyAPIKey") as? String
        let ablyChannel = aDecoder.decodeObject(forKey: "ablyChannel") as? String
        let unreadOrgNotifications = aDecoder.decodeObject(forKey: "unread_count") as? String
        let orgUnreadCounts = aDecoder.decodeObject(forKey: "org_unread_counts") as? [String: String]
        let end_pointList = aDecoder.decodeObject(forKey: "endpoints") as? [[String:String]]
        let mtkAdmin = aDecoder.decodeObject(forKey: "mtk_admin") as? Bool

        self.init(email: email, firstName: firstName, lastName: lastName, avatarUrl: avatarUrl, initialCartCount: initialCartCount, ablyAPIKey: ablyAPIKey, ablyChannel: ablyChannel, unreadOrgNotifications: unreadOrgNotifications, orgUnreadCounts:orgUnreadCounts,end_points: end_pointList, mtkAdmin:mtkAdmin)
    }
}
