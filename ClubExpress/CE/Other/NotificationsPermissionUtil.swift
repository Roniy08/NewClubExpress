//
//  NotificationsPermissionUtil.swift
//  ClubExpress
//
//  Created by Joe Benton on 19/03/2019.
//  Copyright © 2019 Zeta. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationsPermissionStatus {
    case notDetermined
    case authorized
    case denied
}

class NotificationsPermissionUtil {
    static func showNotificationsPermissionPopup(callback: @escaping (_ success: Bool) -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print(error)
            } else {
                callback(success)
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    static func getNotificationsAuthorizationStatus(status: @escaping (NotificationsPermissionStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                status(NotificationsPermissionStatus.notDetermined)
            } else if settings.authorizationStatus == .authorized {
                status(NotificationsPermissionStatus.authorized)
            } else if settings.authorizationStatus == .denied {
                status(NotificationsPermissionStatus.denied)
            }
        }
    }
}
