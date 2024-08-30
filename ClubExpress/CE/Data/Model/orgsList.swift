//
//  orgsList.swift
//  CE
//
//  Created by Ronit Patel on 17/06/24.
//  Copyright © 2024 Zeta. All rights reserved.
//

import Foundation

// MARK: - Org
class OrgsList: NSObject, NSCoding, Decodable {
    let id: String?
    let name: String?
    let imageUrl: String?
    let baseUrl: String?
    let primaryBgColour: String?
    let secondaryBgColour: String?
    let changeOrgMessage: String?
    let timezone: String?
    let internalDomains: Array<String>?
    let checkoutUrl: String?
    let unreadCount: String?
    let memberId: Int
    let tempToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "org_id"
        case name = "org_name"
        case imageUrl = "logo_img"
        case baseUrl = "base_url"
        case primaryBgColour = "primary_bg_color"
        case secondaryBgColour = "secondary_bg_color"
        case changeOrgMessage = "change_org_message"
        case timezone = "timezone"
        case internalDomains = "internal_domains"
        case checkoutUrl = "checkout_url"
        case unreadCount = "unread_count"
        case memberId = "member_id"
        case tempToken = "temp_token"
    }
    
    init(id: String?, name: String?, imageUrl: String?, baseUrl: String?, primaryBgColour: String?, secondaryBgColour: String?, changeOrgMessage: String?, timezone: String?, internalDomains: Array<String>?, checkoutUrl: String?, unreadCount: String?,memberId:Int,tempToken:String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.baseUrl = baseUrl
        self.primaryBgColour = primaryBgColour
        self.secondaryBgColour = secondaryBgColour
        self.changeOrgMessage = changeOrgMessage
        self.timezone = timezone
        self.internalDomains = internalDomains
        self.checkoutUrl = checkoutUrl
        self.unreadCount = unreadCount
        self.memberId = memberId
        self.tempToken = tempToken
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.name = try? container.decode(String.self, forKey: .name)
        self.imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        self.baseUrl = try? container.decode(String.self, forKey: .baseUrl)
        self.primaryBgColour = try? container.decode(String.self, forKey: .primaryBgColour)
        self.secondaryBgColour = try? container.decode(String.self, forKey: .secondaryBgColour)
        self.changeOrgMessage = try? container.decode(String.self, forKey: .changeOrgMessage)
        self.timezone = try? container.decode(String.self, forKey: .timezone)
        self.internalDomains = try? container.decode(Array<String>.self, forKey: .internalDomains)
        self.checkoutUrl = try? container.decode(String.self, forKey: .checkoutUrl)
        self.unreadCount = try? container.decode(String.self, forKey: .unreadCount)
        self.tempToken = try? container.decode(String.self, forKey: .tempToken)
        self.memberId = try! container.decode(Int.self, forKey: .memberId)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.imageUrl, forKey: "imageUrl")
        aCoder.encode(self.baseUrl, forKey:"baseUrl")
        aCoder.encode(self.primaryBgColour, forKey:"primaryBgColor")
        aCoder.encode(self.secondaryBgColour, forKey:"secondaryBgColor")
        aCoder.encode(self.changeOrgMessage, forKey: "changeOrgMessage")
        aCoder.encode(self.timezone, forKey: "timezone")
        aCoder.encode(self.internalDomains, forKey: "internalDomains")
        aCoder.encode(self.checkoutUrl, forKey: "checkoutUrl")
        aCoder.encode(self.unreadCount, forKey: "unreadCount")
        aCoder.encode(self.unreadCount, forKey: "memberId")
        aCoder.encode(self.unreadCount, forKey: "tempToken")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? String
        let name = aDecoder.decodeObject(forKey: "name") as? String
        let imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? String
        let baseUrl = aDecoder.decodeObject(forKey: "baseUrl") as? String
        let primaryBgColour = aDecoder.decodeObject(forKey: "primaryBgColour") as? String
        let secondaryBgColour = aDecoder.decodeObject(forKey: "secondaryBgColour") as? String
        let changeOrgMessage = aDecoder.decodeObject(forKey: "changeOrgMessage") as? String
        let timezone = aDecoder.decodeObject(forKey: "timezone") as? String
        let internalDomains = aDecoder.decodeObject(forKey: "internalDomains") as? Array<String>
        let checkoutUrl = aDecoder.decodeObject(forKey: "checkoutUrl") as? String
        let unreadCount = aDecoder.decodeObject(forKey: "unreadCount") as? String
        let tempToken = aDecoder.decodeObject(forKey: "tempToken") as? String
        let memberId = aDecoder.decodeObject(forKey: "memberId") as! Int
        
        self.init(id: id, name: name, imageUrl: imageUrl, baseUrl: baseUrl, primaryBgColour: primaryBgColour, secondaryBgColour: secondaryBgColour, changeOrgMessage: changeOrgMessage, timezone: timezone, internalDomains: internalDomains, checkoutUrl: checkoutUrl, unreadCount: unreadCount,memberId: memberId, tempToken:tempToken)
    }
}
