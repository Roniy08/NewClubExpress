//
//  NotificationsCountRepository.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024. on 25/03/2019.
//  
//

import Foundation

class NotificationsCountRepository {
    fileprivate var notificationsCountLocalSource: NotificationsCountLocalSource
    
    init(notificationsCountLocalSource: NotificationsCountLocalSource) {
        self.notificationsCountLocalSource = notificationsCountLocalSource
    }
    
    func getUnreadCount() -> Int {
        return notificationsCountLocalSource.getUnreadCount()
    }
    
    func setUnreadCount(count: Int) {
        notificationsCountLocalSource.setUnreadCount(count: count)
    }
    
    func setBadge(orgCount: Int, allOrgCount: [String:String]){
        notificationsCountLocalSource.setBadge(orgCount: orgCount, allOrgCount:allOrgCount)
    }
    
}

