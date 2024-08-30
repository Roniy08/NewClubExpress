//
//  NotificationsCountLocalSource.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 25/03/2019.
//  
//

import Foundation

protocol NotificationsCountLocalSource {
    func setUnreadCount(count: Int)
    func getUnreadCount() -> Int
    func setBadge(orgCount: Int, allOrgCount: [String:String]) -> Void
}

class NotificationsCountLocalSourceImpl: NotificationsCountLocalSource {
    fileprivate var unreadCount = 0 {
        didSet {
            unreadCountDidChange()
        }
    }
    
    func setUnreadCount(count: Int) {
        self.unreadCount = count
    }
    
    func getUnreadCount() -> Int {
        return unreadCount
    }

    fileprivate func unreadCountDidChange() {
        let notificationName = Notification.Name.init("UnreadNotificationsCountDidChange")
        let userInfo = ["unread_count" : self.unreadCount]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
    
    func setBadge(orgCount: Int, allOrgCount: [String:String]){
        var badgeCount = 0
        
        for org in allOrgCount {
            badgeCount += Int(org.value) ?? 0
        }
        
        badgeCount -= orgCount
        
        
        UserDefaults.standard.set("\(badgeCount)", forKey: "otherAppUnreadCount")
        
        let notificationName = Notification.Name.init("SetBadge")
        let userInfo = ["badge_count" : badgeCount]
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
    }
}
